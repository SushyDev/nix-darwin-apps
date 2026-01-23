{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "phpstorm";
	version = "2025.3.2";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}-aarch64.dmg";
			sha256 = "13mhih2ffpb2dg0pc7gw23br4xn1sn9a30y62hnirs2v5ds5qcyp";
		})
		else (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}.dmg";
			sha256 = "0y49x3g8cnxhj04xn5f77kkv9ydnx6w310zvc342spf9562czmxh";
		});

	meta = with pkgs.lib; {
		description = "The PHP IDE for Professional Developers by JetBrains";
		homepage = "https://www.jetbrains.com/phpstorm";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
