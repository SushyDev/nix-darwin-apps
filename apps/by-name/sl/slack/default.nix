{ lib, pkgs, ... }:

lib.mkDmgApp rec {
	pname = "slack";
	version = "4.53.269";

	src = pkgs.fetchurl {
		url = "https://downloads.slack-edge.com/desktop-releases/mac/universal/${version}/Slack-${version}-macOS.dmg";
		sha256 = "0nnilksda8494v1h5v5w5zgksrjrkcwmx340w2l47vkq7hwfmibh";
	};

	meta = with pkgs.lib; {
		description = "Slack desktop application";
		homepage = "https://slack.com";
		license = licenses.unfree;
		maintainers = with maintainers; [ ];
		platforms = platforms.darwin;
	};
}
