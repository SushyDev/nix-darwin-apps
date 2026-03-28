{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "spotify";
	version = "1.2.86.502";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.spotify.com/SpotifyARM64.dmg";
			sha256 = "0j2g85hc41q4jzblsfvdbnfkzhfi5igl7zxbwhh9596lqmkn31fk";
		})
		else (pkgs.fetchurl {
			url = "https://download.spotify.com/Spotify.dmg";
			sha256 = "0244fxlmrna6v6kszspy4y52hypikdqbcyfpanl765kl7gracbi3";
		});

	meta = with pkgs.lib; {
		description = "Spotify is a digital music service that gives you access to millions of songs.";
		homepage = "https://www.spotify.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
