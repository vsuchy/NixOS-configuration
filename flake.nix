{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      disko,
      home-manager,
      nixos-hardware,
      ...
    }:

    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      mkHost =
        {
          modules,
          username,
        }:

        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit nixpkgs-unstable username;
          };

          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
          ]
          ++ modules;
        };
    in

    {
      nixosConfigurations = {
        "thinkpad-p14s" = mkHost {
          username = "vs";
          modules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen6
            ./hosts/thinkpad-p14s/configuration.nix
          ];
        };
        "vmware-fusion" = mkHost {
          username = "vs";
          modules = [
            ./hosts/vmware-fusion/configuration.nix
          ];
        };
      };

      apps = nixpkgs.lib.genAttrs systems (system: {
        disko = {
          type = "app";
          program = "${disko.packages.${system}.disko}/bin/disko";
          meta.description = "Run Disko from the locked flake input";
        };
      });

      devShells = nixpkgs.lib.genAttrs systems (system: {
        ci = nixpkgs.legacyPackages.${system}.mkShellNoCC {
          packages = with nixpkgs.legacyPackages.${system}; [
            deadnix
            nixfmt-tree
            statix
          ];
        };
      });

      formatter = nixpkgs.lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
