{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "vivaldi";
	version = "7.8.3925.76";

	src = pkgs.fetchurl {
		url = "https://downloads.vivaldi.com/stable/Vivaldi.${version}.universal.dmg";
		sha256 = "1021zs3axd1xsgddbqc9ga102xl563839fvvn17wj4ynjw98bzs8";
	};

	meta = with pkgs.lib; {
		description = "The Vivaldi browser";
		homepage = "https://vivaldi.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
