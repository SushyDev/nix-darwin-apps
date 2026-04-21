{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "orbstack";
	version = "2.1.1_20026";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/arm64/OrbStack_v${version}_arm64.dmg";
			sha256 = "01vjv6ks29nhx5plijpqadryvlvqah5q4sv9a44zmqaqk5siz90q";
		})
		else (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/amd64/OrbStack_v${version}_amd64.dmg";
			sha256 = "0g2ic195x0w9pajlarljs3766ainl44255pam78ckalsybqgivn7";
		});

	meta = with pkgs.lib; {
		description = "OrbStack is a Docker Desktop replacement for Mac with Apple Silicon and Intel chips";
		homepage = "https://orbstack.dev";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
