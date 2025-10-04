#!/usr/bin/env bash

set +e

nix develop .#update --command bash -c "./${{ matrix.item.script }}"

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
	echo "status=success" >> "$GITHUB_OUTPUT"

	readonly CURRENT_VERSION="$(nix eval --json .\#packagesInfo.aarch64-darwin.vivaldi.version)"
		echo "current_version=$CURRENT_VERSION" >> "$GITHUB_OUTPUT"

	# Check if there are changes
	if git diff --quiet; then
		echo "has_changes=false" >> "$GITHUB_OUTPUT"
		echo "No changes detected"
	else
		echo "has_changes=true" >> "$GITHUB_OUTPUT"

		# Extract version information from git diff
		OLD_VERSION=$(git diff apps/by-name/${{ matrix.item.package }}/*/default.nix | grep -E '^-.*version = ' | sed -E 's/.*version = "([^"]+)".*/\1/' | head -n1 || echo "unknown")
		NEW_VERSION=$(git diff apps/by-name/${{ matrix.item.package }}/*/default.nix | grep -E '^\+.*version = ' | sed -E 's/.*version = "([^"]+)".*/\1/' | head -n1 || echo "unknown")

		echo "old_version=$OLD_VERSION" >> "$GITHUB_OUTPUT"
		echo "new_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"

		echo "Updated from $OLD_VERSION to $NEW_VERSION"
	fi
else
	echo "status=failed" >> "$GITHUB_OUTPUT"
	echo "has_changes=false" >> "$GITHUB_OUTPUT"
	echo "Update script failed with exit code $EXIT_CODE"
fi
