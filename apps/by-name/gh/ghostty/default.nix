{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "ghostty";
	version = "1.4.0";

	src = pkgs.fetchurl {
		url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
		sha256 = "1s6k31nwxj9fj6bdx3jpqkn56zahwpg43br6hivqsc94pmfhf0is";
	};

	meta = with pkgs.lib; {
		description = "A minimal terminal emulator for macOS";
		homepage = "https://ghostty.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
