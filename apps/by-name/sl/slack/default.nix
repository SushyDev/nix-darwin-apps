{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "slack";
	version = "4.47.72";

	src = pkgs.fetchurl {
		url = "https://downloads.slack-edge.com/desktop-releases/mac/universal/${version}/Slack-${version}-macOS.dmg";
		sha256 = "02y3p69pa0kb1fssz3mrigadrymdpwkmf11ddzia6cv2awi4bmhi";
	};

	meta = with pkgs.lib; {
		description = "Slack desktop application";
		homepage = "https://slack.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
