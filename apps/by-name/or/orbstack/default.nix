{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "orbstack";
	version = "2.2.1_20628";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/arm64/OrbStack_v${version}_arm64.dmg";
			sha256 = "1dcjpwqvlsryqfqirv4p2q79jc27bgbgvsavqrh4qz4q7jf73hav";
		})
		else (pkgs.fetchurl {
			url = "https://cdn-updates.orbstack.dev/amd64/OrbStack_v${version}_amd64.dmg";
			sha256 = "16rid2xlw0x056hwpywyxh9fxypw46mv35b643z99904260ia2pk";
		});

	meta = with pkgs.lib; {
		description = "OrbStack is a Docker Desktop replacement for Mac with Apple Silicon and Intel chips";
		homepage = "https://orbstack.dev";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
