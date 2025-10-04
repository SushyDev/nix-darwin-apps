{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "blender";
	version = "4.5.3";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-arm64.dmg";
			sha256 = "06yh57wzz9smifgqjp7yhwbq5y7icqis5abi7axh8m5mac889skk";
		})
		else (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-x64.dmg";
			sha256 = "065yxqd326nzyxadsx5cbczbvkih9m85rmlsclc7kczixqq8zzf1";
		});

	meta = with pkgs.lib; {
		description = "Blender is the free and open source 3D creation suite.";
		homepage = "https://www.blender.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
