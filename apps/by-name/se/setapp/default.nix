{ lib, pkgs, ... }:

lib.mkZipApp rec {
	pname = "setapp";
	version = "3.47.0";

	src = pkgs.fetchurl {
		url = "https://dl.devmate.com/com.setapp.DesktopClient/126/1755862333/Setapp-126.zip";
		sha256 = "1zgwwv4gm3l8gsb9h2csawjlm37hgw85v3758h4qvc695649z71a";
	};

	meta = with pkgs.lib; {
		description = "Setapp is an app subscription service for Mac and iOS apps.";
		homepage = "https://setapp.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
