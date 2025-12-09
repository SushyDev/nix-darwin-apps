{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "phpstorm";
	version = "2025.3";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}-aarch64.dmg";
			sha256 = "0ayxmc6qkxddwchbl3yrxwifdapqwc7082xh23vwhv8gfiijwv3q";
		})
		else (pkgs.fetchurl {
			url = "https://download-cdn.jetbrains.com/webide/PhpStorm-${version}.dmg";
			sha256 = "1x06r76rkfc3xh8bp0ac8f6fd9fqjc8gys18gcvzv49xkll988dw";
		});

	meta = with pkgs.lib; {
		description = "The PHP IDE for Professional Developers by JetBrains";
		homepage = "https://www.jetbrains.com/phpstorm";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
