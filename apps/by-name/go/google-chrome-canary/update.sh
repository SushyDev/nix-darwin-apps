#!/usr/bin/env bash

set -euo pipefail

source ./scripts/workflow/updater-lib.sh;

readonly SCRIPT_DIR="$(dirname "$0")"
readonly PACKAGE_FILE="${SCRIPT_DIR}/default.nix"

update_package_file() {
	local -r current_version="$1"
	local -r current_sha256="$2"
	local -r new_version="$3"
	local -r new_sha256="$4"

	log_info "Updating package file: $PACKAGE_FILE"

	local -r package_content="$(cat "$PACKAGE_FILE")" || die "Failed to read package file"

	local updated_content="$package_content"

	if [[ -n "$current_version" && -n "$new_version" ]]; then
		updated_content="$(echo "$updated_content" | sed "s,version = \"$current_version\",version = \"$new_version\",")" || die "Failed to update version"
	fi

	if [[ -n "$current_sha256" && -n "$new_sha256" ]]; then
		updated_content="$(echo "$updated_content" | sed "s,sha256 = \"$current_sha256\",sha256 = \"$new_sha256\",")" || die "Failed to update sha256"
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

universal() {
	log_info "Updating universal-darwin"

	read -r current_version current_sha256 < <(get_current_package_info "aarch64-darwin" "google-chrome-canary")

	# Google Chrome Canary URL is static, version detection requires checking the downloaded file
	# We'll use a placeholder version that gets updated based on SHA changes
	local -r download_url="https://dl.google.com/chrome/mac/universal/canary/googlechromecanary.dmg"
	local -r new_sha256="$(fetch_sha256_from_url "$download_url")"

	if [[ $new_sha256 != "" && "$new_sha256" == "$current_sha256" ]]; then
		log_info "No update needed: SHA256 checksum matches current version"
		return
	fi

	# For Chrome Canary, we increment the patch version since we can't easily detect the actual version
	# The version format is arbitrary for this package
	local new_version
	if [[ $current_version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
		local major="${BASH_REMATCH[1]}"
		local minor="${BASH_REMATCH[2]}"
		local patch="${BASH_REMATCH[3]}"
		new_version="$major.$minor.$((patch + 1))"
	else
		# Fallback if version format is unexpected
		new_version="$current_version.1"
	fi

	update_package_file "$current_version" "$current_sha256" "$new_version" "$new_sha256"

	log_info "Update for universal-darwin completed successfully!"
}

main() {
	log_info "Starting Google Chrome Canary update check"

	check_dependencies
	validate_package_file "$PACKAGE_FILE"

	universal

	log_info "Update completed successfully!"
}

main "$@"
