{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "orbstack";
	version = "2.0.4_19887";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/arm64/OrbStack_v${version}_arm64.dmg";
			sha256 = "1nqhb7hzy4c5pi6q6dmpwzz8frxy9vhszmn091j9k8zba03k925s";
		})
		else (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/amd64/OrbStack_v${version}_amd64.dmg";
			sha256 = "1p0y2rld3k15sv16dvpgrjns644g2bh5lh95c2651lw6ah3gif4l";
		});

	meta = with pkgs.lib; {
		description = "OrbStack is a Docker Desktop replacement for Mac with Apple Silicon and Intel chips";
		homepage = "https://orbstack.dev";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
