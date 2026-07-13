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

  outputs = { nixpkgs, disko, home-manager, nixos-hardware, ... }:

  let
    mkHost = system: modules:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
        ] ++ modules;
      };
  in

  {
    nixosConfigurations = {
      "thinkpad-p14s" = mkHost "x86_64-linux" [
        nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen6
        ./hosts/thinkpad-p14s/configuration.nix
      ];
      "vmware-fusion" = mkHost "aarch64-linux" [
        ./hosts/vmware-fusion/configuration.nix
      ];
    };

    apps.x86_64-linux.disko = {
      type = "app";
      program = "${disko.packages.x86_64-linux.disko}/bin/disko";
      meta.description = "Run Disko from the locked flake input";
    };

    apps.aarch64-linux.disko = {
      type = "app";
      program = "${disko.packages.aarch64-linux.disko}/bin/disko";
      meta.description = "Run Disko from the locked flake input";
    };
  };
}
