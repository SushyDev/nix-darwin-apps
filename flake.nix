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
							# 4. Create a name-value pair for the final attribute set
							lib.nameValuePair appName appDerivation
						) appNames
					) letterDirs;
				in
				# 5. Convert the list of pairs into a final attribute set, e.g., { vivaldi = <...>; }
				lib.listToAttrs packageList;
		in
		{
			# The final package set, built for each system
			# Accessible via: nix-darwin-apps.packages.<system>.vivaldi
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
					

			# The recommended way to use these packages: an overlay
			# This will add all our packages to the main `pkgs` set.
			overlays.default = final: prev: 
				# `final` is the final pkgs set, `prev` is the one before our overlay
				# We merge our custom packages into it.
				darwinAppsFor prev;
			
		};
}
