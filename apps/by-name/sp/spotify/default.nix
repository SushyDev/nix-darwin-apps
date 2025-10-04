{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "spotify";
	version = "1.2.73.474";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.spotify.com/SpotifyARM64.dmg";
			sha256 = "0qcgm4y7pncymax1jgb2s7fl0jiszyn0nvcw94883pq9q3b5fxck";
		})
		else (pkgs.fetchurl {
			url = "https://download.spotify.com/Spotify.dmg";
			sha256 = "0zxk8zrshirprgyr1cx9j4nbsiywb9dch4nahlczmga105acmkj9";
		});

	meta = with pkgs.lib; {
		description = "Spotify is a digital music service that gives you access to millions of songs.";
		homepage = "https://www.spotify.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
