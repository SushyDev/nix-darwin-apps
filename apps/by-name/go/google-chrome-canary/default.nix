{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "google-chrome-canary";
	version = "4.5.23";

	src = pkgs.fetchurl {
		url = "https://dl.google.com/chrome/mac/universal/canary/googlechromecanary.dmg";
		sha256 = "148hv0ci7894v52ws1jx254fwfdj2igb9339qkjr8dp3m4ck00y2";
	};

	meta = with pkgs.lib; {
		description = "Google Chrome Canary browser";
		homepage = "https://www.google.com/chrome/canary";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
