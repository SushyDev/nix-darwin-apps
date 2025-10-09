{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "orbstack";
	version = "2.0.3_19876";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/arm64/OrbStack_v${version}_arm64.dmg";
			sha256 = "03pjk4zvvpnxgnk3bnbaxri211ji4khgdl9f9pkiz0c46p9mrynw";
		})
		else (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/amd64/OrbStack_v${version}_amd64.dmg";
			sha256 = "0n6qb7xnxgk9f4p1v6qmn1r3ib6ja15bqvzb5p3ki62af75756pq";
		});

	meta = with pkgs.lib; {
		description = "OrbStack is a Docker Desktop replacement for Mac with Apple Silicon and Intel chips";
		homepage = "https://orbstack.dev";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
