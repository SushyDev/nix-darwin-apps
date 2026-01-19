{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "dbeaver";
	version = "25.3.3";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-aarch64.dmg";
			sha256 = "1w2ipmi35gv5g45y31w7m8v4qgfc6a6mx37rlh5096fyl4w1631v";
		})
		else (pkgs.fetchurl {
			url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-x86_64.dmg";
			sha256 = "1hhlh4370dlwjyayy1gks7nszfvvrpwwgkwdh1bk1w5x9wwzfm5g";
		});

	meta = with pkgs.lib; {
		description = "Free universal database tool";
		homepage = "https://dbeaver.io";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
