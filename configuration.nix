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
  boot.initrd.verbose = false;

  environment.systemPackages = with pkgs; [
    git wget vim curl foot hyprpaper kitty waybar neovim nodejs python3
    lua5_1 luarocks gcc gnumake unzip rofi hyprlock hypridle grim slurp
    wl-clipboard cliphist tree-sitter ripgrep lazygit gh opencode

    awww

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

    john hashcat gnupg age

    binwalk exiftool foremost sleuthkit testdisk libewf

    wireshark

    ghidra radare2 cutter

    gdb lldb cmake pkg-config patchelf checksec elfutils strace ltrace valgrind rr

    python3Packages.pip python3Packages.virtualenv

    openssh sshpass git-lfs zip jq yq fd bat

    imagemagick pngcheck optipng

    ffmpeg mediainfo

    util-linux parted gptfdisk

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
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ];
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
