#!/usr/bin/env bash

set -euo pipefail

source ./scripts/workflow/updater-lib.sh;

readonly SCRIPT_DIR="$(dirname "$0")"
readonly PACKAGE_FILE="${SCRIPT_DIR}/default.nix"

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

	if [[ -n "$current_sha256" && -n "$new_sha256" ]]; then
		updated_content="$(echo "$updated_content" | sed -E "s/sha256 = \"$current_sha256\"/sha256 = \"$new_sha256\"/")" || die "Failed to update sha256"
	fi

	[ -n "$updated_content" ] || die "Updated content is empty"

	cp "$PACKAGE_FILE" "${PACKAGE_FILE}.backup" || die "Failed to create backup"

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

	local -r download_pattern='href="[^\"]*macos-arm64.dmg"'
	local -r download_extract_pattern='s/href="//;s/"//'
	local -r version_pattern='blender-([0-9.]+)-macos-arm64\.dmg'
	local -r version_extract_pattern='s/blender-([0-9.]+)-macos-arm64\.dmg/\1/'

	local -r page_content="$(fetch_page_content)"
	local -r download_url="$(extract_download_url "$page_content" $download_pattern $download_extract_pattern)"
	local -r new_version="$(extract_version_from_url "$download_url" $version_pattern $version_extract_pattern)"
	local -r new_sha256="$(fetch_sha256_from_url "$download_url")"

	if [[ $new_sha256 != "" && "$new_sha256" == "$current_sha256" ]]; then
		log_info "No update needed: SHA256 checksum matches current version"
		return
	fi

	update_package_file "$current_version" "$current_sha256" "$new_version" "$new_sha256"

	log_info "Update for aarch64-darwin completed successfully!"
}

x86_64() {
	log_info "Checking for updates on x86_64-darwin"

	read -r current_version current_sha256 < <(get_current_package_info "x86_64-darwin" "blender")

	local -r download_pattern='href="[^\"]*macos-x64.dmg"'
	local -r download_extract_pattern='s/href="//;s/"//'
	local -r version_pattern='blender-([0-9.]+)-macos-x64\.dmg'
	local -r version_extract_pattern='s/blender-([0-9.]+)-macos-x64\.dmg/\1/'

	local -r page_content="$(fetch_page_content)"
	local -r download_url="$(extract_download_url "$page_content" $download_pattern $download_extract_pattern)"
	local -r new_version="$(extract_version_from_url "$download_url" $version_pattern $version_extract_pattern)"
	local -r new_sha256="$(fetch_sha256 "$download_url")"

	if [[ $new_sha256 != "" && "$new_sha256" == "$current_sha256" ]]; then
		log_info "No update needed: SHA256 checksum matches current version"
		return
	fi

	update_package_file "$current_version" "$current_sha256" "$new_version" "$new_sha256"

	log_info "Update for x86_64-darwin completed successfully!"
}

main() {
	log_info "Starting Blender update check"

	check_dependencies
	validate_package_file "$PACKAGE_FILE"

	aarch64
	x86_64

	log_info "Update completed successfully!"
}

main "$@"
