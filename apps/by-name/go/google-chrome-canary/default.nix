{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "google-chrome-canary";
	version = "4.5.6";

	src = pkgs.fetchurl {
		url = "https://dl.google.com/chrome/mac/universal/canary/googlechromecanary.dmg";
		sha256 = "0l7iig80flzm31wcp72vqdf3jsbj1gmf6axhkihcd8rmmhkl8gir";
	};

	meta = with pkgs.lib; {
		description = "Google Chrome Canary browser";
		homepage = "https://www.google.com/chrome/canary";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
