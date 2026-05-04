{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "orbstack";
	version = "2.1.0_19993";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/arm64/OrbStack_v${version}_arm64.dmg";
			sha256 = "1hzlj5smnr27xnj7zrrxi87a207hgbljr5idfgnjw0jk7ynbgp35";
		})
		else (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/amd64/OrbStack_v${version}_amd64.dmg";
			sha256 = "06crringbmadjd5kaj3jjws3yvbcq0q7y6c0bf9rb7ai0wa2vl64";
		});

	meta = with pkgs.lib; {
		description = "OrbStack is a Docker Desktop replacement for Mac with Apple Silicon and Intel chips";
		homepage = "https://orbstack.dev";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
