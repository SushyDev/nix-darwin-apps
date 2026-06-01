{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "dbeaver";
	version = "26.1.0";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-aarch64.dmg";
			sha256 = "0j586ygfa8phrz94kmcz96n7jf3nqng9mxzn4wlj8dkp3bk51qxk";
		})
		else (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-x86_64.dmg";
			sha256 = "1fpcckhf2r1kikirvlnw858hf8nibhdpj2igp0mrf9a53yyxgmr0";
		});

	meta = with pkgs.lib; {
		description = "Free universal database tool";
		homepage = "https://dbeaver.io";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
