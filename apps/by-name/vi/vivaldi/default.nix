{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "vivaldi";
	version = "8.1.4087.58";

	src = pkgs.fetchurl {
		url = "https://downloads.vivaldi.com/stable/Vivaldi.${version}.universal.dmg";
		sha256 = "1jaldv8j83931fvgafv8xq6snzgw7k97w4hiypcij86wdwpa3b4v";
	};

	meta = with pkgs.lib; {
		description = "The Vivaldi browser";
		homepage = "https://vivaldi.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
