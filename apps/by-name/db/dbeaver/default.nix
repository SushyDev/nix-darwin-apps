{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "dbeaver";
	version = "26.1.1";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-aarch64.dmg";
			sha256 = "01wkh68jrpa1a5fw0ywxnrz34vcp06qkcc19zw312s1y8708a2rz";
		})
		else (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-x86_64.dmg";
			sha256 = "12h5dkcp4rvkly8yv45xlqw557d1x4zdjhk8wy6bgq8w66xwfr0j";
		});

	meta = with pkgs.lib; {
		description = "Free universal database tool";
		homepage = "https://dbeaver.io";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
