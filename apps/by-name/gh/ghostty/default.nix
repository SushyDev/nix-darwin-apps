{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "ghostty";
	version = "1.3.0";

	src = pkgs.fetchurl { 
		url = "https://release.files.ghostty.org/1.2.3/Ghostty.dmg";
		sha256 = "1i8c3p9lq3bxxccgmgdnznkj4m96vzsxp7rvq04804c217krizjk";
	};

	meta = with pkgs.lib; {
		description = "A minimal terminal emulator for macOS";
		homepage = "https://ghostty.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
