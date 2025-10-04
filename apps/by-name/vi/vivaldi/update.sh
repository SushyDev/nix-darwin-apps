#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$0")"
readonly PACKAGE_FILE="${SCRIPT_DIR}/default.nix"

log_info() {
	echo "[INFO] $*" >&2
}

log_error() {
	echo "[ERROR] $*" >&2
}

die() {
	log_error "$*"
	exit 1
}

check_dependencies() {
	local -a missing_deps=()

	for cmd in curl jq nix nix-prefetch-url sed grep; do
		if ! command -v "$cmd" &> /dev/null; then
			missing_deps+=("$cmd")
		fi
	done

	if [ ${#missing_deps[@]} -gt 0 ]; then
		die "Missing required dependencies: ${missing_deps[*]}"
	fi
}

validate_package_file() {
	[ -f "$PACKAGE_FILE" ] || die "Package file not found: $PACKAGE_FILE"
	[ -r "$PACKAGE_FILE" ] || die "Package file not readable: $PACKAGE_FILE"
	[ -w "$PACKAGE_FILE" ] || die "Package file not writable: $PACKAGE_FILE"
}

get_current_package_info() {
	log_info "Reading current package information"

	local package_json
	package_json="$(nix eval --json .#packagesInfo.aarch64-darwin.vivaldi 2>/dev/null)" || \
		die "Failed to evaluate Nix package information"

	[ -n "$package_json" ] || die "Empty package information received"

	local version sha256
	version="$(echo "$package_json" | jq -r .version 2>/dev/null)" || \
		die "Failed to parse version from package JSON"
	sha256="$(echo "$package_json" | jq -r .sha256 2>/dev/null)" || \
		die "Failed to parse sha256 from package JSON"

	[ -n "$version" ] && [ "$version" != "null" ] || die "Invalid version in package JSON"
	[ -n "$sha256" ] && [ "$sha256" != "null" ] || die "Invalid sha256 in package JSON"

	echo "$version" "$sha256"
}

fetch_page_content() {
	local fetch_url="https://vivaldi.com/download/"
	log_info "Fetching page content from $fetch_url"

	local content
	content="$(curl -sL --fail --max-time 30 "$fetch_url" 2>/dev/null)" || \
		die "Failed to fetch page content from $fetch_url"

	[ -n "$content" ] || die "Received empty page content"

	echo "$content"
}

extract_download_url() {
	local content="$1"
	local pattern='https://downloads\.vivaldi\.com/stable/Vivaldi\.[0-9.]+\.universal\.dmg'
	local replace_pattern="$pattern"

	log_info "Extracting download URL"

	local download_url
	download_url="$(echo "$content" | grep -oE "$pattern" | head -n 1)"

	[ -n "$download_url" ] || die "Failed to extract download URL from page content"

	echo "$download_url"
}

extract_version_from_url() {
	local url="$1"
	local pattern='Vivaldi\.([0-9.]+)\.universal\.dmg'
	local replace_pattern='s/Vivaldi\.([0-9.]+)\.universal\.dmg/\1/'

	log_info "Extracting version from download URL"

	local version
	version="$(echo "$url" | grep -oP "$pattern" | sed -E "$replace_pattern")"

	[ -n "$version" ] || die "Failed to extract version from URL: $url"

	echo "$version"
}

compare_versions() {
	local new_version="$1"
	local current_version="$2"

	log_info "Comparing versions: current=$current_version, new=$new_version"

	local result
	result=$(nix eval --impure --raw --expr "builtins.toString (builtins.compareVersions \"$new_version\" \"$current_version\")" 2>/dev/null) || \
		die "Failed to compare versions"

	echo "$result"
}

fetch_sha256() {
	local url="$1"

	log_info "Fetching SHA256 checksum for new version"

	local sha256
	sha256="$(nix-prefetch-url "$url" 2>/dev/null)" || \
		die "Failed to fetch SHA256 checksum from $url"

	[ -n "$sha256" ] || die "Received empty SHA256 checksum"

	echo "$sha256"
}

update_package_file() {
	local new_version="$1"
	local new_sha256="$2"

	log_info "Updating package file: $PACKAGE_FILE"

	local package_content updated_content
	package_content="$(cat "$PACKAGE_FILE")" || die "Failed to read package file"

	updated_content="$(
		echo "$package_content" | \
		sed -E "s/version = \"[^\"]+\"/version = \"$new_version\"/" | \
		sed -E "s/sha256 = \"[^\"]+\"/sha256 = \"$new_sha256\"/"
	)" || die "Failed to update package content"

	[ -n "$updated_content" ] || die "Updated content is empty"

	# Create backup before modifying
	cp "$PACKAGE_FILE" "${PACKAGE_FILE}.backup" || die "Failed to create backup"

	# Write updated content
	echo "$updated_content" > "$PACKAGE_FILE" || {
		mv "${PACKAGE_FILE}.backup" "$PACKAGE_FILE"
		die "Failed to write updated package file (backup restored)"
	}

	rm "${PACKAGE_FILE}.backup"

	log_info "Successfully updated $PACKAGE_FILE"
	log_info "Version: $new_version"
	log_info "SHA256: $new_sha256"
}

main() {
	log_info "Starting Vivaldi update check"

	check_dependencies
	validate_package_file

	read -r current_version current_sha256 < <(get_current_package_info)

	validate_sha256 "$current_sha256"

	local page_content download_url new_version
	page_content="$(fetch_page_content)"
	download_url="$(extract_download_url "$page_content")"
	new_version="$(extract_version_from_url "$download_url")"

	local comparison_result
	comparison_result="$(compare_versions "$new_version" "$current_version")"

	if [ "$comparison_result" -ne 1 ]; then
		log_info "No update needed. Current version ($current_version) is up to date with available version ($new_version)."
		exit 0
	fi

	log_info "New version available"

	local new_sha256
	new_sha256="$(fetch_sha256 "$download_url")"
	validate_sha256 "$new_sha256"

	update_package_file "$new_version" "$new_sha256"

	log_info "Update completed successfully!"
}

main "$@"
