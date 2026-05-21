{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "phpstorm";
	version = "2026.1.2";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}-aarch64.dmg";
			sha256 = "0242jsnir33d1rqbqh1ym7dbdlwkjz1p1s0b1hn5pr43ixssm4vl";
		})
		else (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}.dmg";
			sha256 = "1jnys1dq6vvy1i2bbb6xyhgb6w4aj0x54i1l64xdpwniqvkjydjz";
		});

	meta = with pkgs.lib; {
		description = "The PHP IDE for Professional Developers by JetBrains";
		homepage = "https://www.jetbrains.com/phpstorm";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
