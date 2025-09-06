{
	description = "nix-darwin-apps";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
	};

	outputs = { self, nixpkgs } @ inputs:
		let
			systems = [ "x86_64-darwin" "aarch64-darwin" ];
			forAllSystems = nixpkgs.lib.genAttrs systems;

			darwinAppsFor = pkgs:
				let
					lib = nixpkgs.lib;
					appsPath = ./apps/by-name;

					letterDirs = lib.attrNames (builtins.readDir appsPath);

					packageList = lib.concatMap (letter:
						let
							letterPath = appsPath + "/${letter}";
							appNames = lib.attrNames (builtins.readDir letterPath);
						in
						lib.map (appName:
							let
								appPath = letterPath + "/${appName}/default.nix";
								appDerivation = (import appPath) {
									inherit inputs pkgs; 
									lib = import (./lib/default.nix) {
										inherit pkgs;
									};
								};
							in
							lib.nameValuePair appName appDerivation
						) appNames
					) letterDirs;
				in
				lib.listToAttrs packageList;
		in
		{
			packages = 
				let
					pkgs = system: import nixpkgs { 
						inherit system;
						config = { 
							allowUnfree = true;
						};
					};
				in
				forAllSystems (system: darwinAppsFor (pkgs system));

			overlays.default = final: prev: darwinAppsFor prev;
		};
}
