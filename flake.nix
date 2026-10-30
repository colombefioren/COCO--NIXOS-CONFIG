{
  description = "dellillah - NixOS + Hyprland + illogical-impulse";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    illogical-flake = {
      url = "github:shuntia/illogical-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    areofyl-fetch = {
      url = "github:areofyl/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # end4-pC quickshell config, pinned to an exact commit so `nix flake update`
    # never moves it; bump the rev here to upgrade.
    end4-pC = {
      url = "github:pctrade/end4-pC/f1fb69c6f3f2727e5cd73223a8f56525125565ea";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, illogical-flake, areofyl-fetch, zen-browser, spicetify-nix, end4-pC, ... }: {
    nixosConfigurations.dellillah = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit zen-browser spicetify-nix end4-pC; };

          home-manager.users.cocofioren = {
            imports = [
              illogical-flake.homeManagerModules.default
              areofyl-fetch.homeManagerModules.default
              spicetify-nix.homeManagerModules.default
              ./home.nix
            ];
          };
        }
      ];
    };
  };
}
