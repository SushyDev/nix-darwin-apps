{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "vivaldi";
	version = "7.7.3851.61";

	src = pkgs.fetchurl {
		url = "https://downloads.vivaldi.com/stable/Vivaldi.${version}.universal.dmg";
		sha256 = "07g3k79w4m6p7qxmp2r64nfgsjk0mky6bgw8gbgg5qg15pbb4lsa";
	};

	meta = with pkgs.lib; {
		description = "The Vivaldi browser";
		homepage = "https://vivaldi.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
