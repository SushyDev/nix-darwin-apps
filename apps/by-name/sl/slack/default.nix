{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "slack";
	version = "4.52.178";

	src = pkgs.fetchurl {
		url = "https://downloads.slack-edge.com/desktop-releases/mac/universal/${version}/Slack-${version}-macOS.dmg";
		sha256 = "0vqigrvdff8d46y11fmdk65zh1whdgf00r78ncc2qm85p0ic42c9";
	};

	meta = with pkgs.lib; {
		description = "Slack desktop application";
		homepage = "https://slack.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
