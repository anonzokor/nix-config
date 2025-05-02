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

  };

  outputs = { self, nixpkgs, home-manager, nvchad4nix, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

      extraSpecialArgs = { inherit inputs system; };
      specialArgs = { inherit inputs system; };
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./configuration.nix

            home-manager.nixosModules.home-manager {
              home-manager = {
                inherit extraSpecialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.q = ./home.nix;  # ← pass the path, not the result of import
              };
            }
          ];
        };
      };
    };
}

