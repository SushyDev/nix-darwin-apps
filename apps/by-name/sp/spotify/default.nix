{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "spotify";
	version = "1.2.73.474";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.spotify.com/SpotifyARM64.dmg";
			sha256 = "0x6svwzcgkhps0n9237kcplq7l35h38zjl52s969014bvak2h36j";
		})
		else (pkgs.fetchurl {
			url = "https://download.spotify.com/Spotify.dmg";
			sha256 = "0yjh1ynd0d44v2yrbgppr8rcwyafkiynl6hkin0bphgcp4ny2aph";
		});

	meta = with pkgs.lib; {
		description = "Spotify is a digital music service that gives you access to millions of songs.";
		homepage = "https://www.spotify.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
