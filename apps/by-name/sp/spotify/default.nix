{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "spotify";
	version = "1.2.78.418";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.spotify.com/SpotifyARM64.dmg";
			sha256 = "0d2xc7xlj5wv9f1q28wkjysfmhszp4vnhsvx7n3kd3x9jf2x7fpy";
		})
		else (pkgs.fetchurl {
			url = "https://download.spotify.com/Spotify.dmg";
			sha256 = "0pcd7ajzajhymb1qppma4qazr7smwad76d0jf5vry7kg5x6m0srp";
		});

	meta = with pkgs.lib; {
		description = "Spotify is a digital music service that gives you access to millions of songs.";
		homepage = "https://www.spotify.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
