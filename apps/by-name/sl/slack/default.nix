{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "slack";
	version = "4.49.81";

	src = pkgs.fetchurl {
		url = "https://downloads.slack-edge.com/desktop-releases/mac/universal/${version}/Slack-${version}-macOS.dmg";
		sha256 = "1vlvp0w1l9xyiaipq5wvpfys8ipb7sygzjjmxg7ilx2rv2vbcgbc";
	};

	meta = with pkgs.lib; {
		description = "Slack desktop application";
		homepage = "https://slack.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
