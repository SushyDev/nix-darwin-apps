{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "vivaldi";
	version = "8.2.4133.87";

	src = pkgs.fetchurl {
		url = "https://downloads.vivaldi.com/stable/Vivaldi.${version}.universal.dmg";
		sha256 = "17w1j53kxmkwwq00skr20g4745c9a2ix89qxsa6vl0g3fv9piznp";
	};

	meta = with pkgs.lib; {
		description = "The Vivaldi browser";
		homepage = "https://vivaldi.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
