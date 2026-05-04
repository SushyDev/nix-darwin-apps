{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "spotify";
	version = "1.2.87.415";

	src = if pkgs.stdenv.hostPlatform.isAarch64 
		then (pkgs.fetchurl {
			url = "https://download.spotify.com/SpotifyARM64.dmg";
			sha256 = "1iwg2jdnq62iflk8fqn9ryzb1lp955i4x1rpc02c6625h4s2hw9l";
		})
		else (pkgs.fetchurl {
			url = "https://download.spotify.com/Spotify.dmg";
			sha256 = "0mxaxhniias1ajfjpya72igyrqbd6z6yhiw2yr1n06rv5ybb28aq";
		});

	meta = with pkgs.lib; {
		description = "Spotify is a digital music service that gives you access to millions of songs.";
		homepage = "https://www.spotify.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
