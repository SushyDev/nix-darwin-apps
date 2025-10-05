#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$0")"
readonly PACKAGE_FILE="${SCRIPT_DIR}/default.nix"

fetch_page_content() {
	local -r fetch_url="$1"

	log_info "Fetching page content from $fetch_url"

	local -r content="$(curl -sL --fail --max-time 30 "$fetch_url" 2>/dev/null)" || \
		die "Failed to fetch page content from $fetch_url"

	[ -n "$content" ] || die "Received empty page content"

	echo "$content"
}

extract_download_url() {
	local -r content="$1"
	local -r pattern="$2"

	log_info "Extracting download URL"

	local -r download_url="$(echo "$content" | grep -oE "$pattern" | head -n 1)"

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
	set -f

	log_info "Updating aarch64-darwin"

	read -r current_version current_sha256 < <(get_current_package_info "aarch64-darwin" "phpstorm")

	local -r page_url='https://data.services.jetbrains.com/products/releases?code=PS'
	local -r download_pattern="https://download\.jetbrains\.com/webide/PhpStorm-[0-9.]+-aarch64\.dmg"
	local -r version_pattern='PhpStorm-([0-9.]+)-aarch64\.dmg'
	local -r version_extract_pattern='s/PhpStorm-([0-9.]+)-aarch64\.dmg/\1/'

	local -r page_content="$(fetch_page_content $page_url)"
	local -r download_url="$(extract_download_url "$page_content" $download_pattern)"
	local -r new_version="$(extract_version_from_url "$download_url" $version_pattern $version_extract_pattern)"
	local -r new_sha256="$(fetch_sha256 "$download_url")"

	if [[ $new_sha256 != "" && "$new_sha256" == "$current_sha256" ]]; then
		log_info "No update needed: SHA256 checksum matches current version"
		return
	fi

	update_package_file "$current_version" "$current_sha256" "$new_version" "$new_sha256"

	log_info "Update for aarch64-darwin completed successfully!"

	set +f
}

x86_64() {
	set -f

	log_info "Updating x86_64-darwin"

	read -r current_version current_sha256 < <(get_current_package_info "x86_64-darwin" "phpstorm")

	local -r page_url='https://data.services.jetbrains.com/products/releases?code=PS'
	local -r download_pattern="https://download\.jetbrains\.com/webide/PhpStorm-[0-9.]+\.dmg"
	local -r version_pattern='PhpStorm-([0-9.]+)\.dmg'
	local -r version_extract_pattern='s/PhpStorm-([0-9.]+)\.dmg/\1/'

	local -r page_content="$(fetch_page_content $page_url)"
	local -r download_url="$(extract_download_url "$page_content" $download_pattern)"
	local -r new_version="$(extract_version_from_url "$download_url" $version_pattern $version_extract_pattern)"
	local -r new_sha256="$(fetch_sha256_from_url "$download_url")"

	if [[ $new_sha256 != "" && "$new_sha256" == "$current_sha256" ]]; then
		log_info "No update needed: SHA256 checksum matches current version"
		return
	fi

	update_package_file "$current_version" "$current_sha256" "$new_version" "$new_sha256"

	log_info "Update for x86_64-darwin completed successfully!"

	set +f
}

main() {
	log_info "Starting PhpStorm update check"

	check_dependencies
	validate_package_file "$PACKAGE_FILE"

	aarch64
	x86_64

	log_info "Update completed successfully!"
}

main "$@"
