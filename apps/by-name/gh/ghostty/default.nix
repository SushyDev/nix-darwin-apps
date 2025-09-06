{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "ghostty";
	version = "1.1.3";

	src = pkgs.fetchurl { 
		url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
		sha256 = "0ir69yhqia8yj2i750g2aklk7wr9vzwbdp6ncvqri5aliwc19rb4";
	};

	meta = with pkgs.lib; {
		description = "A minimal terminal emulator for macOS";
		homepage = "https://ghostty.org";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
