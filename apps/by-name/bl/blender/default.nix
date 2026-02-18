{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "blender";
	version = "4.5.7";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-arm64.dmg";
			sha256 = "0107ygiw6y1yfm1xvmhdsbgxias43jbj853v3gb9zrzbhqs3b7p1";
		})
		else (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-x64.dmg";
			sha256 = "1a5120qckpp2dphwxkg4ldrmacc6h2gqp1jr5744jk5csgzd5ikv";
		});

	meta = with pkgs.lib; {
		description = "Blender is the free and open source 3D creation suite.";
		homepage = "https://www.blender.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
