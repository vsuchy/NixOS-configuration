{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

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

  outputs = inputs@{ nixpkgs, disko, home-manager, ... }:

  let
    configuration = import ./hosts/VSThinkPad/configuration.nix;
    host = configuration.host;
  in

  {
    apps.${host.platform}.disko = {
      type = "app";
      program = "${disko.packages.${host.platform}.disko}/bin/disko";
      meta.description = "Run Disko from the locked flake input";
    };

    nixosConfigurations.${host.hostname} = nixpkgs.lib.nixosSystem {
      system = host.platform;

      modules = [
        configuration.module
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
      ];
      specialArgs = {
        inherit inputs host;
        disk = host.disk;
      };
    };
  };
}
