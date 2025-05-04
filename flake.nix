{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    slippi.url = "github:lytedev/slippi-nix";


  };

  outputs = { self, nixpkgs, home-manager, nvchad4nix, slippi, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib; # shortens access to nixpkgs to lib

      # manually imports nixpkgs for system for use within the flake
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

#       extraSpecialArgs = { inherit inputs system; };
      extraSpecialArgs = {
        system = system;
        nvchad4nix = inputs.nvchad4nix;
        slippi = inputs.slippi;
      };

      specialArgs = { inherit inputs system; };

    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system specialArgs;

          modules = [
            ./configuration.nix

            slippi.nixosModules.default

            home-manager.nixosModules.home-manager {
              home-manager = {
                inherit extraSpecialArgs;
                useGlobalPkgs = true; # home-manager uses same pkgs as nix
                useUserPackages = true; # system installs user packages
                users.q = ./home.nix;  # use home.nix to manage configurations for user "q"

              };
            }
          ];
        };
      };
    };
}

