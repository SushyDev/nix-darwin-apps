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
				local SOURCE_IMAGE="$1"
				hdiutil attach -readonly -nobrowse "$SOURCE_IMAGE"
			}

			function extract_mount_point() {
				local HDIUTIL_OUTPUT="$1"
				echo "$HDIUTIL_OUTPUT" | awk '/\/dev\/disk/ { $1=""; $2=""; print $0 }' | xargs
			}

			function copy_files() {
				local SOURCE_DIR="$1"
				local DESTINATION_DIR="$2"
				find "$SOURCE_DIR" -maxdepth 2 -name "*.app" -exec cp -R {} "$DESTINATION_DIR" \;
			}

			function cleanup_mount_point() {
				local POINT_TO_DETACH="$1"

				echo "Detaching disk image at $POINT_TO_DETACH"
				hdiutil detach -quiet "$POINT_TO_DETACH"
			}

			PATH="$PATH:/usr/bin"

			echo "Attaching disk image: $src"
			DISK_IMAGE_INFO=$(attach_disk_image "$src")
			echo "Disk image info: $DISK_IMAGE_INFO"

			echo "Extracting mount point from hdiutil output"
			MOUNT_POINT=$(extract_mount_point "$DISK_IMAGE_INFO")
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
