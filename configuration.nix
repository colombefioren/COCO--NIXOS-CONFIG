{ config, lib, pkgs, ... }:
let
  polishcowPlymouth = pkgs.stdenvNoCC.mkDerivation {
    pname = "plymouth-theme-polishcow";
    version = "1.0.0";
    src = ./plymouth-polishcow;
    dontBuild = true;
    installPhase = ''
      themedir=$out/share/plymouth/themes/polishcow
      mkdir -p "$themedir/images"
      cp polishcow.plymouth polishcow.script "$themedir/"
      cp images/*.png "$themedir/images/"
      sed -i "s,^ImageDir=.*,ImageDir=$themedir/images," "$themedir/polishcow.plymouth"
      sed -i "s,^ScriptFile=.*,ScriptFile=$themedir/polishcow.script," "$themedir/polishcow.plymouth"
    '';
  };
  # cupp (Common User Passwords Profiler) is not in nixpkgs; build it from the
  # upstream repo pinned to a master commit (no releases are tagged). cupp loads
  # cupp.cfg from its own directory via realpath(__file__), so both files live in
  # share/cupp and a wrapper runs the script with python3.
  cupp = pkgs.stdenvNoCC.mkDerivation {
    pname = "cupp";
    version = "3.3.0-unstable-2024-05-08";
    src = pkgs.fetchFromGitHub {
      owner = "Mebus";
      repo = "cupp";
      rev = "b77f1ae66c10ab2d0fa09c67017949fb5ba187aa";
      hash = "sha256-eNE8DUFtFFEfBsm3TrL3GcnBXPQ7x0kfzZHH49Jqy5w=";
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out/share/cupp"
      cp cupp.py cupp.cfg "$out/share/cupp/"
      makeWrapper ${pkgs.python3}/bin/python3 "$out/bin/cupp" \
        --add-flags "$out/share/cupp/cupp.py"
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # 16G swap for memory-heavy local workloads.
  # The file is created manually: dd if=/dev/zero of=/swapfile bs=1M count=16384 && mkswap /swapfile
  swapDevices = [ { device = "/swapfile"; size = 16384; } ];

  # If home-manager activation finds a colliding file (e.g. the upstream fish
  # config), move it aside with this suffix instead of aborting, so the
  # home-manager-cocofioren.service succeeds at login.
  home-manager.backupFileExtension = "hmbak";

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    gfxmodeEfi = "auto";
    theme = ./grub-theme;
    extraEntries = ''
      menuentry "Windows Boot Manager" --class windows --class os {
        insmod part_gpt
        insmod fat
        search --no-floppy --fs-uuid --set=root 4CE1-A6B8
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
      menuentry "Fedora Linux" --class fedora --class gnu-linux --class gnu --class os {
        insmod part_gpt
        insmod fat
        search --no-floppy --fs-uuid --set=root 4CE1-A6B8
        chainloader /EFI/fedora/grubx64.efi
      }
    '';
  };

  boot.plymouth = {
    enable = true;
    theme = "polishcow";
    themePackages = [ polishcowPlymouth ];
  };
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [ "quiet" "splash" ];
  boot.consoleLogLevel = 3;

  environment.systemPackages = with pkgs; [
    git wget vim curl foot hyprpaper kitty waybar neovim nodejs-bin python3
    lua5_1 luarocks gcc gnumake unzip rofi hyprlock hypridle grim slurp
    wl-clipboard cliphist tree-sitter ripgrep lazygit gh opencode

    awww

    whatsapp-electron

    adwaita-icon-theme
    hicolor-icon-theme
    papirus-icon-theme

    pavucontrol
    playerctl
    brightnessctl
    blueman
    polkit_gnome

    file findutils fd tree jq yq less bat zip p7zip xz gzip bzip2 zstd gnutar
    gnugrep gawk gnused coreutils binutils

    nmap socat tcpdump traceroute iproute2 dnsutils whois openssl inetutils
    gobuster ffuf nikto sqlmap httpie

    john hashcat gnupg age cupp

    binwalk exiftool foremost sleuthkit testdisk libewf steghide

    wireshark

    ghidra radare2

    gdb lldb cmake pkg-config patchelf checksec elfutils strace ltrace valgrind rr

    python3Packages.pip python3Packages.virtualenv

    openssh sshpass git-lfs zip jq yq fd bat

    imagemagick pngcheck optipng

    ffmpeg mediainfo

    util-linux parted gptfdisk

    samba

    man man-pages
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = 1;
  services.getty.autologinUser = "cocofioren";
  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;
  networking.hostName = "dellillah";

  time.timeZone = "Indian/Antananarivo";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  users.users.cocofioren = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.upower.enable = true;

  fonts.packages = with pkgs; [
    rubik
    nerd-fonts.ubuntu
    nerd-fonts.jetbrains-mono
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
  };

  programs.dconf.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Phone / MTP access (Android) + iPhone (usbmuxd)
  services.udev.packages = [ pkgs.libmtp ];
  services.usbmuxd.enable = true;

  hardware.graphics.enable = true;

  services.geoclue2.enable = true;
  services.postgresql = {
  enable = true;
  package = pkgs.postgresql_18;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  nixpkgs.overlays = [
    # nixpkgs still ships Node.js 24.21.0, which has the Brotli decoder remote
    # code execution (CVE-2026-111497) fixed in the 24.22.1 security release.
    # Until nixpkgs catches up, use the official prebuilt binaries patched for
    # NixOS; the hash matches https://nodejs.org/dist/v24.22.1/SHASUMS256.txt.
    # Drop this overlay and go back to nodejs once nixpkgs has 24.22.1 or later.
    (final: prev: {
      nodejs-bin = final.stdenv.mkDerivation (finalAttrs: {
        pname = "nodejs-bin";
        version = "24.22.1";
        src = final.fetchurl {
          url = "https://nodejs.org/dist/v${finalAttrs.version}/node-v${finalAttrs.version}-linux-x64.tar.xz";
          hash = "sha256-bBcqmrZxj3uAH7WnvUhq8u5eMnWAhqBLhPzOKqdwleY=";
        };
        nativeBuildInputs = [ final.autoPatchelfHook ];
        buildInputs = [ final.stdenv.cc.cc.lib ];
        installPhase = ''
          mkdir -p "$out"
          cp -r bin include lib share "$out/"
        '';
        # npm, npx and corepack start with "#!/usr/bin/env node": point them at this node
        preFixup = ''
          export HOST_PATH="$out/bin:$HOST_PATH"
        '';
        meta.mainProgram = "node";
      });
    })
    (final: prev: {
      python3 = prev.python3.override {
        packageOverrides = pyFinal: pyPrev: {
          kde-material-you-colors = pyPrev.kde-material-you-colors.overridePythonAttrs (old: {
            propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pyFinal.python-magic ];
          });
        };
      };
      python3Packages = final.python3.pkgs;
    })
  ];

  system.stateVersion = "26.05";
}
