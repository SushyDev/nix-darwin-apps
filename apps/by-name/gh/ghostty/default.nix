{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "ghostty";
	version = "1.3.1";

	src = pkgs.fetchurl { 
		url = "https://release.files.ghostty.org/1.2.3/Ghostty.dmg";
		sha256 = "0saziwxpkjqy5issl57jp902l9cah170dly7v7m0xsfflsqg5kqq";
	};

	meta = with pkgs.lib; {
		description = "A minimal terminal emulator for macOS";
		homepage = "https://ghostty.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
