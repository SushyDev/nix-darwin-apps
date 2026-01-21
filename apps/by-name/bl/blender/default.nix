{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "blender";
	version = "4.5.6";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-arm64.dmg";
			sha256 = "1qdgb0pjgg04flpmhv78zvhxng2qhbjbpshb52m5idk6bgl2p202";
		})
		else (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-x64.dmg";
			sha256 = "04vpbyfds1zmaxh2wlv0qpk21dca9viif0z07iksk0bkr11b9220";
		});

	meta = with pkgs.lib; {
		description = "Blender is the free and open source 3D creation suite.";
		homepage = "https://www.blender.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
