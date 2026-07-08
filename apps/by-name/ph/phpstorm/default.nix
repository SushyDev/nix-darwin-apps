{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "phpstorm";
	version = "2026.1.4";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}-aarch64.dmg";
			sha256 = "09m9ml43aj6q117vvsbqf7glsm5i0da5mzs4pshbny67c48iyrsw";
		})
		else (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}.dmg";
			sha256 = "13hmkxim1sw67c4w9zridky28jnm0ypmwbdfwwsippnjxri31cav";
		});

	meta = with pkgs.lib; {
		description = "The PHP IDE for Professional Developers by JetBrains";
		homepage = "https://www.jetbrains.com/phpstorm";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
