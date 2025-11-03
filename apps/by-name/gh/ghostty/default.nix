{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "ghostty";
	version = "1.2.3";

	src = pkgs.fetchurl { 
		url = "https://release.files.ghostty.org/1.2.3/Ghostty.dmg";
		sha256 = "0sr0hg28aafd5lx8izq7ni25nmy7k18g9ppqp5x04a3f24gyjppk";
	};

	meta = with pkgs.lib; {
		description = "A minimal terminal emulator for macOS";
		homepage = "https://ghostty.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
