{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "dbeaver";
	version = "25.3.4";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-aarch64.dmg";
			sha256 = "1jigdspi081c9wws0vrg26gcpb6k04da7jj8vk8v8mw0fhfikwmb";
		})
		else (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-x86_64.dmg";
			sha256 = "06m33mfsrrb27mq2vvd692rdmn91lvbjwvh2498jj5bivh9lr6hc";
		});

	meta = with pkgs.lib; {
		description = "Free universal database tool";
		homepage = "https://dbeaver.io";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
