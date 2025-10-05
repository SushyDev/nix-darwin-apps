{ pkgs, ... }:
let
	mkDmgApp = { pname, version, src, meta }: pkgs.stdenv.mkDerivation rec {
		inherit pname version src meta;

		phases = [ "unpackPhase" "installPhase" ];
		dontFixup = true;
		dontStrip = true;

		unpackPhase = ''
			runHook preUnpack

			function attach_disk_image() {
				local -r source_image="$1"
				echo "Attaching disk image: $source_image" >&2
				hdiutil attach -readonly -nobrowse "$source_image"
			}

			function extract_mount_point() {
				local -r hdiutil_output="$1"
				echo "Extracting mount point from hdiutil output" >&2
				echo "$hdiutil_output" | awk '/\/dev\/disk/ { $1=""; $2=""; print $0 }' | xargs
			}

			function copy_files() {
				local -r source_dir="$1"
				local -r destination_dir="$2"
				find "$source_dir" -maxdepth 2 -name "*.app" -exec cp -R {} "$destination_dir" \;
			}

			function cleanup_mount_point() {
				local -r point_to_detach="$1"
				echo "Detaching disk image at $point_to_detach" >&2
				hdiutil detach -quiet "$point_to_detach"
			}

			PATH="$PATH:/usr/bin"

			readonly DISK_IMAGE_INFO=$(attach_disk_image "$src")
			echo "Disk image info: $DISK_IMAGE_INFO"

			readonly MOUNT_POINT=$(extract_mount_point "$DISK_IMAGE_INFO")
			echo "Mount point: $MOUNT_POINT"

			if [[ -z "$MOUNT_POINT" || ! -d "$MOUNT_POINT" ]]; then
				echo "Failed to mount disk image or mount point not found"
				exit 1
			fi
			
			trap "cleanup_mount_point '$MOUNT_POINT'" EXIT
			
			echo "Copying .app files from $MOUNT_POINT to $PWD"
			copy_files "$MOUNT_POINT" "$PWD"
			
			runHook postUnpack
		'';

		sourceRoot = ".";

		installPhase = ''
			runHook preInstall

			mkdir -p $out/Applications
			cp -R *.app $out/Applications

			runHook postInstall
		'';
	};

	mkZipApp = { pname, version, src, meta }: pkgs.stdenv.mkDerivation rec {
		inherit pname version src meta;

		nativeBuildInputs = [ pkgs.unzip ];

		installPhase = ''
			runHook preInstall

			mkdir -p $out/Applications
			unzip -q "$src" -d $out/Applications

			runHook postInstall
		'';
	};

	mkPkgApp = { pname, version, src, meta }: pkgs.stdenv.mkDerivation rec {
		inherit pname version src meta;

		phases = [ "installPhase" ];

		sourceRoot = ".";

		installPhase = ''
			runHook preInstall

			PATH="$PATH:/usr/sbin"

			mkdir -p $out/Applications

			installer -pkg "$src" -target /

			runHook postInstall
		'';
	};
in 
{ 
	inherit mkDmgApp mkZipApp mkPkgApp;
}
