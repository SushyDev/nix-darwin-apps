{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "slack";
	version = "4.52.171";

	src = pkgs.fetchurl {
		url = "https://downloads.slack-edge.com/desktop-releases/mac/universal/${version}/Slack-${version}-macOS.dmg";
		sha256 = "0zr3xqpfk0h38szi5w47gr5fn4fnl1hrdlvyv68f2kddpq98g4in";
	};

	meta = with pkgs.lib; {
		description = "Slack desktop application";
		homepage = "https://slack.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
