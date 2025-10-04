#!/usr/bin/env bash

set +e

readonly NAME="$1"
readonly SCRIPT="$2"

nix develop .#update --command bash -c "./$SCRIPT"

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
	echo "status=success" >> "$GITHUB_OUTPUT"

	readonly NEW_VERSION=$(nix eval --raw .\#packagesInfo.aarch64-darwin.vivaldi.version)
		echo "new_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"

	if git diff --quiet; then
		echo "has_changes=false" >> "$GITHUB_OUTPUT"
	else
		echo "has_changes=true" >> "$GITHUB_OUTPUT"
	fi
else
	echo "status=failed" >> "$GITHUB_OUTPUT"
	echo "has_changes=false" >> "$GITHUB_OUTPUT"
	echo "Update script failed with exit code $EXIT_CODE"
fi
