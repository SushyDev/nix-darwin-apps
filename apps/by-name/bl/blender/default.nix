{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "blender";
	version = "4.5.2";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-arm64.dmg";
			sha256 = "0bc20xnawv8xm4hp7ams1301nwm5q3y8k8hq7lmnrihmv80is6g5";
		})
		else (pkgs.fetchurl {
			url = "https://download.blender.org/release/Blender4.5/blender-${version}-macos-x64.dmg";
			sha256 = "1s99b446zzd508v52a5v3clmv7gfl61whk8pmpy9b5ad8zr9y93v";
		});

	meta = with pkgs.lib; {
		description = "Blender is the free and open source 3D creation suite.";
		homepage = "https://www.blender.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
