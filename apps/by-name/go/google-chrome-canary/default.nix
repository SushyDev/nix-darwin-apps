{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "google-chrome-canary";
	version = "4.5.12";

	src = pkgs.fetchurl {
		url = "https://dl.google.com/chrome/mac/universal/canary/googlechromecanary.dmg";
		sha256 = "1vjnk9llkazj89zb2vqsp59h640nwdbr3a6mlw2ps29wwrblm1bw";
	};

	meta = with pkgs.lib; {
		description = "Google Chrome Canary browser";
		homepage = "https://www.google.com/chrome/canary";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
