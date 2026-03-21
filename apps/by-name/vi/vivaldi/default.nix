{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "vivaldi";
	version = "7.9.3970.41";

	src = pkgs.fetchurl {
		url = "https://downloads.vivaldi.com/stable/Vivaldi.${version}.universal.dmg";
		sha256 = "0cnmjj7qhlq43gp7123wwd8r5r93q1g1h40f7wdr23ridwii442v";
	};

	meta = with pkgs.lib; {
		description = "The Vivaldi browser";
		homepage = "https://vivaldi.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
