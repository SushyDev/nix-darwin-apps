{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "google-chrome-canary";
	version = "4.5.4";

	src = pkgs.fetchurl {
		url = "https://dl.google.com/chrome/mac/universal/canary/googlechromecanary.dmg";
		sha256 = "1wjww4vmqv9fs49qy5mzs4wvf4nz95xnld2rbnrcpy5pmhl404qq";
	};

	meta = with pkgs.lib; {
		description = "Google Chrome Canary browser";
		homepage = "https://www.google.com/chrome/canary";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
