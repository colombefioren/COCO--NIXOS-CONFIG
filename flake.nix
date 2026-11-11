{
  description = "dellillah - NixOS + Hyprland + illogical-impulse";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # GNOME 50 stack (nautilus 50.4, gtk 4.22, libadwaita 1.9) for Nautilus only: the
    # end-4 matugen stylesheet is written for libadwaita 1.9 and renders badly on 1.10.
    nixpkgs-gnome50.url = "github:NixOS/nixpkgs/nixos-26.05";

    # brave was dropped from nixpkgs on 2026-11-03 (unmaintained); keep its
    # expression from the last nixpkgs that still had it and bump the .deb below.
    nixpkgs-brave.url = "github:NixOS/nixpkgs/31ecbaca1bdefa45dffc409f0250bd8039ea0010";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    illogical-flake = {
      url = "github:shuntia/illogical-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        dotfiles.follows = "dotfiles";
        quickshell.follows = "quickshell";
      };
    };

    # end-4 dotfiles and quickshell tracked directly so `nix flake update` moves
    # them; illogical-flake otherwise keeps its own stale pins of both.
    dotfiles = {
      url = "git+https://github.com/end-4/dots-hyprland?submodules=1";
      flake = false;
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
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
      url = "github:pctrade/end4-pC/8135351525a916778bc3ead276a85095c6c1e59b";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-brave, nixpkgs-gnome50, home-manager, illogical-flake, areofyl-fetch, zen-browser, spicetify-nix, end4-pC, ... }: {
    nixosConfigurations.dellillah = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        {
          nixpkgs.overlays = [
            (final: prev: {
              brave = nixpkgs-brave.legacyPackages.x86_64-linux.brave;
              inherit (nixpkgs-gnome50.legacyPackages.x86_64-linux) nautilus sushi file-roller;
            })
          ];
        }

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
