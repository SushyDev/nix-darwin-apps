{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "blender";
	version = "4.5.4";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-arm64.dmg";
			sha256 = "0q6d2dd7hna489nbk1zbbjy7ib7ni2vj37ng6mbzc2izaq3xhsvx";
		})
		else (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-x64.dmg";
			sha256 = "0gjm2cq0zgrnawasx98zzibvr9vd7zn31m4i8pqffl42dk6xb54i";
		});

	meta = with pkgs.lib; {
		description = "Blender is the free and open source 3D creation suite.";
		homepage = "https://www.blender.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
