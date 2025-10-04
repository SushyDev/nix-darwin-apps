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
	local -r arch="$1"
	local -r package="$2"

	log_info "Reading current package information"

	local -r package_json="$(nix eval --json .#packagesInfo.$arch.$package 2>/dev/null)" || \
		die "Failed to evaluate Nix package information"

	[ -n "$package_json" ] || die "Empty package information received"

	local -r version="$(echo "$package_json" | jq -r .version 2>/dev/null)" || \
		die "Failed to parse version from package JSON"
	local -r sha256="$(echo "$package_json" | jq -r .sha256 2>/dev/null)" || \
		die "Failed to parse sha256 from package JSON"

	[ -n "$version" ] && [ "$version" != "null" ] || die "Invalid version in package JSON"
	[ -n "$sha256" ] && [ "$sha256" != "null" ] || die "Invalid sha256 in package JSON"

	echo "$version" "$sha256"
}

fetch_page_content() {
	local -r fetch_url="https://download.blender.org/release/Blender4.5/"

	log_info "Fetching page content from $fetch_url"

	local -r content="$(curl -sL --fail --max-time 30 "$fetch_url" 2>/dev/null)" || \
		die "Failed to fetch page content from $fetch_url"

	[ -n "$content" ] || die "Received empty page content"

	echo "$content"
}

extract_download_url() {
	local -r content="$1"
	local -r pattern="$2"
	local -r replace_pattern="$3"

	log_info "Extracting download URL"

	local -r download_url="https://download.blender.org/release/Blender4.5/$(echo "$content" | grep -o "$pattern" | tail -n 1 | sed -E "$replace_pattern")"

	[ -n "$download_url" ] || die "Failed to extract download URL from page content"

	echo "$download_url"
}

extract_version_from_url() {
	local -r url="$1"
	local -r pattern="$2"
	local -r replace_pattern="$3"

	log_info "Extracting version from download URL"

	local -r version="$(echo "$url" | grep -oP "$pattern" | sed -E "$replace_pattern")"

	[ -n "$version" ] || die "Failed to extract version from URL: $url"

	echo "$version"
}

compare_versions() {
	local -r new_version="$1"
	local -r current_version="$2"

	log_info "Comparing versions: current=$current_version, new=$new_version"

	local -r result=$(nix eval --impure --raw --expr "builtins.toString (builtins.compareVersions \"$new_version\" \"$current_version\")" 2>/dev/null) || \
		die "Failed to compare versions"

	echo "$result"
}

fetch_sha256() {
	local -r url="$1"

	log_info "Fetching SHA256 checksum for new version"

	local -r sha256="$(nix-prefetch-url "$url" 2>/dev/null)" || \
		die "Failed to fetch SHA256 checksum from $url"

	[ -n "$sha256" ] || die "Received empty SHA256 checksum"

	echo "$sha256"
}

update_package_file() {
	local -r current_version="$1"
	local -r current_sha256="$2"
	local -r new_version="$3"
	local -r new_sha256="$4"

	log_info "Updating package file: $PACKAGE_FILE"

	local -r package_content="$(cat "$PACKAGE_FILE")" || die "Failed to read package file"

	local updated_content="$package_content"

	if [[ -n "$current_version" && -n "$new_version" ]]; then
		updated_content="$(echo "$updated_content" | sed -E "s/version = \"$current_version\"/version = \"$new_version\"/")" || die "Failed to update version"
	fi

	# Replace current hash with new hash if found
	if [[ -n "$current_sha256" && -n "$new_sha256" ]]; then
		updated_content="$(echo "$updated_content" | sed -E "s/sha256 = \"$current_sha256\"/sha256 = \"$new_sha256\"/")" || die "Failed to update sha256"
	fi

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

aarch64() {
	log_info "Checking for updates on aarch64-darwin"

	read -r current_version current_sha256 < <(get_current_package_info "aarch64-darwin" "blender")

	local -r DOWNLOAD_PATTERN='href="[^\"]*macos-arm64.dmg"'
	local -r DOWNLOAD_EXTRACT_PATTERN='s/href="//;s/"//'
	local -r VERSION_PATTERN='blender-([0-9.]+)-macos-arm64\.dmg'
	local -r VERSION_EXTRACT_PATTERN='s/blender-([0-9.]+)-macos-arm64\.dmg/\1/'

	local page_content download_url new_version
	page_content="$(fetch_page_content)"
	download_url="$(extract_download_url "$page_content" $DOWNLOAD_PATTERN $DOWNLOAD_EXTRACT_PATTERN)"
	new_version="$(extract_version_from_url "$download_url" $VERSION_PATTERN $VERSION_EXTRACT_PATTERN)"

	local comparison_result
	comparison_result="$(compare_versions "$new_version" "$current_version")"

	if [ "$comparison_result" -ne 1 ]; then
		log_info "No update needed. Current version ($current_version) is up to date with available version ($new_version)."
		return
		exit 0
	fi

	log_info "New version available"

	local new_sha256
	new_sha256="$(fetch_sha256 "$download_url")"

	update_package_file "$current_version" "$current_sha256" "$new_version" "$new_sha256"

	log_info "Update for aarch64-darwin completed successfully!"
}

x86_64() {
	log_info "Checking for updates on x86_64-darwin"

	read -r current_version current_sha256 < <(get_current_package_info "x86_64-darwin" "blender")

	local -r DOWNLOAD_PATTERN='href="[^\"]*macos-x64.dmg"'
	local -r DOWNLOAD_EXTRACT_PATTERN='s/href="//;s/"//'
	local -r VERSION_PATTERN='blender-([0-9.]+)-macos-x64\.dmg'
	local -r VERSION_EXTRACT_PATTERN='s/blender-([0-9.]+)-macos-x64\.dmg/\1/'

	local -r page_content="$(fetch_page_content)"
	local -r download_url="$(extract_download_url "$page_content" $DOWNLOAD_PATTERN $DOWNLOAD_EXTRACT_PATTERN)"
	local -r new_version="$(extract_version_from_url "$download_url" $VERSION_PATTERN $VERSION_EXTRACT_PATTERN)"

	log_info "New version available"

	local -r new_sha256="$(fetch_sha256 "$download_url")"

	update_package_file "$current_version" "$current_sha256" "$new_version" "$new_sha256"

	log_info "Update for x86_64-darwin completed successfully!"
}

main() {
	log_info "Starting Blender update check"

	check_dependencies
	validate_package_file

	aarch64
	x86_64

	log_info "Update completed successfully!"
}

main "$@"
