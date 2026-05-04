{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "dbeaver";
	version = "26.0.4";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-aarch64.dmg";
			sha256 = "015y2shmi4kpv4wjvqxmy7kpi1hr36nz7lg952khs9yajdi4yhs6";
		})
		else (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-x86_64.dmg";
			sha256 = "1yx0s854qrv99h9hdjcpxi399qapmx489yr5ak0g8a8kl0b280dy";
		});

	meta = with pkgs.lib; {
		description = "Free universal database tool";
		homepage = "https://dbeaver.io";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
