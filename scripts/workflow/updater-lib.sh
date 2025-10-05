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
	local -r required_deps=(curl jq nix nix-prefetch-url sed grep)
	local -a missing_deps=()

	for cmd in required_deps; do
		if ! command -v "$cmd" &> /dev/null; then
			missing_deps+=("$cmd")
		fi
	done

	if [ ${#missing_deps[@]} -gt 0 ]; then
		die "Missing required dependencies: ${missing_deps[*]}"
	fi
}

validate_package_file() {
	local -r package_file="$1"

	[ -f "$package_file" ] || die "Package file not found: $package_file"
	[ -r "$package_file" ] || die "Package file not readable: $package_file"
	[ -w "$package_file" ] || die "Package file not writable: $package_file"
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

fetch_sha256_from_url() {
	local -r url="$1"

	log_info "Fetching SHA256 checksum for new version"

	local -r sha256="$(nix-prefetch-url "$url" 2>/dev/null)" || \
		die "Failed to fetch SHA256 checksum from $url"

	[ -n "$sha256" ] || die "Received empty SHA256 checksum"

	echo "$sha256"
}

