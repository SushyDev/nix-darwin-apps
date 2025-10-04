{
	description = "nix-darwin-apps";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
	};

	outputs = { self, nixpkgs } @ inputs:
		let
			systems = [ "x86_64-darwin" "aarch64-darwin" ];
			forAllSystems = nixpkgs.lib.genAttrs systems;

			getPkgs = system: import nixpkgs { 
				inherit system;
				config = { 
					allowUnfree = true;
				};
			};

			darwinAppsFor = pkgs:
				let
					lib = import (./lib/default.nix) { inherit pkgs; };
					appsPath = ./apps/by-name;
					letterDirs = nixpkgs.lib.attrNames (builtins.readDir appsPath);
					packageList = nixpkgs.lib.concatMap (letter:
						let
							letterPath = appsPath + "/${letter}";
							appNames = nixpkgs.lib.attrNames (builtins.readDir letterPath);
						in
						nixpkgs.lib.map (appName:
							let
								appPath = letterPath + "/${appName}/default.nix";
								appDerivation = (import appPath) {
									inherit inputs lib pkgs;
								};
							in
							nixpkgs.lib.nameValuePair appName appDerivation
						) appNames
					) letterDirs;
				in
				nixpkgs.lib.listToAttrs packageList;

			getInfo = packages:
				nixpkgs.lib.mapAttrs (name: pkg: {
					inherit name;
					version = pkg.version or "unknown";
					sha256 = pkg.src.outputHash or "unknown";
					url = builtins.head pkg.src.urls or "unknown";
				}) packages;
		in
		{
			inherit systems;

			packages = forAllSystems (system:
				let
					pkgs = system: getPkgs system;
				in
				darwinAppsFor (pkgs system)
			);

			packagesInfo = forAllSystems (system:
				let
					pkgs = system: getPkgs system;
				in
				getInfo (darwinAppsFor (pkgs system))
			);

			overlays.default = final: prev: darwinAppsFor prev;

			devShells = forAllSystems (system:
				let
					pkgs = getPkgs system;
				in
				{
					update = pkgs.mkShell {
						buildInputs = with pkgs; [
							bash
							curl
							jq
							nix
							gnugrep
							gnused
							coreutils
						];
					};
				});
		};
}
