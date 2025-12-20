{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "phpstorm";
	version = "2025.3.1";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}-aarch64.dmg";
			sha256 = "1g0nmz2j29km0hd586r1z1dhin2icy1g4j4cggwwphw6xskf0lq4";
		})
		else (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}.dmg";
			sha256 = "1lfj9a5c2psnb4kfrgzydid5jab0hczcvskslqg2fjyrwp78p60i";
		});

	meta = with pkgs.lib; {
		description = "The PHP IDE for Professional Developers by JetBrains";
		homepage = "https://www.jetbrains.com/phpstorm";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
