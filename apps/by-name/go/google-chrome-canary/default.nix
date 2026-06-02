{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "google-chrome-canary";
	version = "4.5.51";

	src = pkgs.fetchurl {
		url = "https://dl.google.com/chrome/mac/universal/canary/googlechromecanary.dmg";
		sha256 = "0rb345cppaq0cyjixw8nlbgprw5791xfa35mxfvlkv7c7jj24lda";
	};

	meta = with pkgs.lib; {
		description = "Google Chrome Canary browser";
		homepage = "https://www.google.com/chrome/canary";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
