{
  config,
  lib,
  pkgs,
  zen-browser,
  spicetify-nix,
  ...
}:

{
  home.username = "cocofioren";
  home.homeDirectory = "/home/cocofioren";
  home.stateVersion = "26.05";

  home.activation.writeMyHyprKeybinds = lib.hm.dag.entryAfter [ "copyIllogicalImpulseConfigs" ] ''
        mkdir -p "$HOME/.config/hypr/custom"
        # The shell binds SUPER+B to the left AI sidebar; it collides with our SUPER+B -> brave, so drop it.
        sed -i '/hl.bind("SUPER + B"/d' "$HOME/.config/hypr/hyprland/keybinds.lua"
        cat > "$HOME/.config/hypr/custom/keybinds.lua" << 'LUAEOF'
    local mainMod = "SUPER"

    hl.config({
      input = {
        kb_layout = "fr",
        touchpad = {
          clickfinger_behavior = true,
          natural_scroll = true,
        },
      },
    })

    hl.unbind(mainMod .. "+RETURN")
    hl.unbind(mainMod .. "+Return")
    hl.bind(mainMod .. "+RETURN", hl.dsp.exec_cmd("kitty"))
    hl.bind(mainMod .. "+A", hl.dsp.exec_cmd("qs -c end4-pC ipc call sidebarLeft toggle"), { description = "Left sidebar" })
    hl.unbind(mainMod .. "+N")
    hl.bind(mainMod .. "+N", hl.dsp.exec_cmd("kitty -e nvim"), { description = "Neovim" })
    hl.unbind(mainMod .. "+P")
    hl.bind(mainMod .. "+P", hl.dsp.exec_cmd("qs -c end4-pC ipc call sidebarRight toggle"), { description = "Right sidebar" })
    hl.bind(mainMod .. "+L", hl.dsp.exec_cmd("qs -c end4-pC ipc call lock activate"), { description = "Lock screen" })
    hl.bind(mainMod .. "+Escape", hl.dsp.exec_cmd("qs -c end4-pC ipc call settingsToggle"), { description = "Settings" })
    hl.bind(mainMod .. "+comma", hl.dsp.exec_cmd("qs -c end4-pC ipc call bar toggle"), { description = "Toggle bar" })
    hl.bind(mainMod .. "+SHIFT+R", hl.dsp.exec_cmd("pkill -f 'qs-wrapped -c end4-[p]C' || true; sleep 1; pkill -9 -f 'qs-wrapped -c end4-[p]C' || true; qs -c end4-pC >/dev/null 2>&1 &"), { description = "Reload shell" })
    hl.unbind(mainMod .. "+S")
    hl.bind(mainMod .. "+S",
      hl.dsp.exec_cmd([[qs -p ~/.config/quickshell/end4-pC ipc call region screenshot]]),
      { description = "Screenshot region" })
    hl.bind(mainMod .. "+V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. "+F", hl.dsp.window.fullscreen({ action = "toggle" }))
    hl.bind(mainMod .. "+SHIFT+F", hl.dsp.exec_cmd("/home/cocofioren/.local/bin/spotify-fad-toggle"), { description = "Spotify full display toggle" })
    hl.bind(mainMod .. "+ALT+left",  hl.dsp.window.swap({ direction = "left" }))
    hl.bind(mainMod .. "+ALT+right", hl.dsp.window.swap({ direction = "right" }))
    hl.bind(mainMod .. "+ALT+up",    hl.dsp.window.swap({ direction = "up" }))
    hl.bind(mainMod .. "+ALT+down",  hl.dsp.window.swap({ direction = "down" }))
    hl.bind(mainMod .. "+SHIFT+left",  hl.dsp.window.move({ direction = "left" }))
    hl.bind(mainMod .. "+SHIFT+right", hl.dsp.window.move({ direction = "right" }))
    hl.bind(mainMod .. "+SHIFT+up",    hl.dsp.window.move({ direction = "up" }))
    hl.bind(mainMod .. "+SHIFT+down",  hl.dsp.window.move({ direction = "down" }))
    hl.bind(mainMod .. "+Q", hl.dsp.window.close())
    hl.bind(mainMod .. "+SPACE", hl.dsp.exec_cmd("rofi -show drun"))
    hl.unbind(mainMod .. "+E")
    hl.bind(mainMod .. "+E", hl.dsp.exec_cmd("nautilus"), { description = "Files: Nautilus" })
    hl.bind(mainMod .. "+Y", hl.dsp.exec_cmd("kitty -1 fish -c yazi"), { description = "Files: Yazi" })
    hl.bind(mainMod .. "+B", hl.dsp.exec_cmd("brave"))
    hl.unbind(mainMod .. "+W")
    hl.bind(mainMod .. "+W", hl.dsp.exec_cmd("brave"))
    hl.bind(mainMod .. "+SHIFT+1", hl.dsp.window.move({ workspace = "1", follow = true }))
    hl.bind(mainMod .. "+SHIFT+2", hl.dsp.window.move({ workspace = "2", follow = true }))
    hl.bind(mainMod .. "+right", hl.dsp.window.cycle_next({ next = true }))
    hl.bind(mainMod .. "+left",  hl.dsp.window.cycle_next({ false }))
    hl.bind(mainMod .. "+down",  hl.dsp.window.cycle_next({ next = true }))
    hl.bind(mainMod .. "+up",    hl.dsp.window.cycle_next({ false }))
    for i = 1, 10 do
      hl.bind(mainMod .. "+F" .. i, hl.dsp.window.move({ workspace = tostring(i), follow = true }))
    end
    LUAEOF
        chmod u+w "$HOME/.config/hypr/custom/keybinds.lua"

        cat > "$HOME/.config/hypr/custom/variables.lua" << 'LUAEOF'
    hl.env("qsConfig", "end4-pC")
    browser = "brave"
    LUAEOF
        chmod u+w "$HOME/.config/hypr/custom/variables.lua"

        cat > "$HOME/.config/hypr/custom/late.lua" << 'LUAEOF'
    hl.config({
      input = {
        kb_layout = "fr",
        touchpad = {
          natural_scroll = true,
        },
        sensitivity = 0.5,
        accel_profile = "flat",
      },
    })

    -- Glassmorphism: translucent windows with strong blur (loaded last, wins over shell defaults)
    hl.config({
      decoration = {
        active_opacity = 0.92,
        inactive_opacity = 0.8,
        blur = {
          size = 10,
          ignore_opacity = true,
        },
      },
    })

    -- Brave: full opacity when active, like every other window when inactive
    hl.window_rule({ match = { class = "^(brave-browser)$" }, opacity = "1 0.8" })
    hl.window_rule({ match = { class = "^(brave)$" }, opacity = "1 0.8" })

    -- Spotify: translucent glass player — blurred wallpaper shows through
    hl.window_rule({ match = { class = "^(spotify)$" }, opacity = "0.86 0.82" })

    -- btop: much more transparent so the blur shows through its very dark UI
    hl.window_rule({ match = { title = "^btop$" }, opacity = "0.55 0.45" })

    -- Rofi launcher: blur behind it like the shell layers, clipped to its rounded shape
    hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.1 })

    hl.gesture({
        fingers = 3,
        direction = "left",
        action = function()
            hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
        end
    })
    hl.gesture({
        fingers = 3,
        direction = "right",
        action = function()
            hl.dispatch(hl.dsp.focus({ workspace = "-1" }))
        end
    })
    LUAEOF
        chmod u+w "$HOME/.config/hypr/custom/late.lua"

        if ! grep -q 'require("custom.late")' "$HOME/.config/hypr/hyprland.lua" 2>/dev/null; then
          echo 'require("custom.late")' >> "$HOME/.config/hypr/hyprland.lua"
        fi
        sed -i 's/action = "move"/action = "workspace"/' "$HOME/.config/hypr/hyprland/general.lua"
        sed -i 's/direction = "swipe"/direction = "vertical"/' "$HOME/.config/hypr/hyprland/general.lua"
        sed -i '/-- Disable blur for every window/,+1d' "$HOME/.config/hypr/hyprland/rules.lua"
        sed -i 's|hyprctl setcursor [^ ]* [0-9]*|hyprctl setcursor pikachu-cursor 32|' "$HOME/.config/hypr/hyprland/execs.lua"
        if ! grep -q 'XCURSOR_THEME' "$HOME/.config/hypr/hyprland/env.lua" 2>/dev/null; then
          printf '\nhl.env("XCURSOR_THEME", "pikachu-cursor")\nhl.env("XCURSOR_SIZE", "32")\n' >> "$HOME/.config/hypr/hyprland/env.lua"
        fi
  '';

  home.activation.installEnd4pC = lib.hm.dag.entryAfter [ "copyIllogicalImpulseConfigs" ] ''
    END4_DIR="$HOME/.config/quickshell/end4-pC"
    END4_PIN=f1fb69c6f3f2727e5cd73223a8f56525125565ea
    if [ ! -d "$END4_DIR/.git" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git init "$END4_DIR"
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$END4_DIR" remote add origin https://github.com/pctrade/end4-pC.git
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$END4_DIR" fetch --depth 1 origin "$END4_PIN" || true
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$END4_DIR" reset --hard FETCH_HEAD
    elif [ "$(${pkgs.git}/bin/git -C "$END4_DIR" rev-parse HEAD 2>/dev/null)" != "$END4_PIN" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$END4_DIR" fetch --depth 1 origin "$END4_PIN" || true
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$END4_DIR" reset --hard "$END4_PIN"
    fi
    sed -i "s/primary_paletteKeyColor/primaryPaletteKeyColor/" "$END4_DIR/scripts/colors/generate_colors_material.py"
    if ! grep -q 'magick png:' "$END4_DIR/modules/common/utils/ScreenshotAction.qml" 2>/dev/null; then
      sed -i 's|const cropBase = `magick |const cropBase = `magick png:|' "$END4_DIR/modules/common/utils/ScreenshotAction.qml"
    fi
    sed -i '/function screenshot() {/,/^    }/ s/if (Persistent.states.record.enable) {/{/' "$END4_DIR/modules/ii/regionSelector/RegionSelector.qml"
  '';

  # Install pre-built opencode v1.18.31 to ~/.local/bin/opencode (takes
  # precedence over the nix system path via PATH order). v1.18.30 has a
  # critical bug — TypeError in SystemPrompt.environment causes "Unexpected
  # server error" on every message. The nixpkgs source build has a
  # version-dependent node_modules hash that prevents simple overrideAttrs,
  # so we ship the upstream pre-built binary instead.
  home.activation.installOpenCode = lib.hm.dag.entryAfter [ "writeMyHyprKeybinds" ] ''
    OC_URL="https://github.com/anomalyco/opencode/releases/download/v1.18.31/opencode-linux-x64.tar.gz"
    OC_SHA256="e9312be75ed803b7415fc2aeabda1f4fe938912a39673762dc0c38c0e11ebde4"
    OC_BIN="$HOME/.local/bin/opencode"

    if ! [ "$("$OC_BIN" --version 2>/dev/null)" = "1.18.31" ]; then
      mkdir -p "$HOME/.local/bin"
      tmp="$(mktemp -d)"
      ${pkgs.curl}/bin/curl -sSL "$OC_URL" -o "$tmp/opencode.tar.gz"
      echo "$OC_SHA256  $tmp/opencode.tar.gz" | ${pkgs.coreutils}/bin/sha256sum -c -
      tar xzf "$tmp/opencode.tar.gz" -C "$tmp"
      cp "$tmp/opencode" "$OC_BIN"
      chmod +x "$OC_BIN"
      rm -rf "$tmp"
    fi
  '';

  # Boot the graphical-session.target at login. xdg-desktop-portal won't start
  # otherwise (Requisite=graphical-session.target), which breaks OBS screen
  # capture and app screen-share. graphical-session.target refuses manual
  # starts, so it has to be pulled as a dependency of a Wants= unit.
  systemd.user.services.boot-graphical-session = {
    Unit = {
      Description = "Activate the graphical session target (needed by xdg-desktop-portal)";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.audio-volume-boost = {
    Unit = {
      Description = "Boost built-in audio volume to 150%";
      After = [ "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'export PATH=/run/current-system/sw/bin:$PATH; for i in $(seq 1 30); do id=$(wpctl status | sed -n \"/Sinks:/,/Sources:/p\" | grep \"Built-in Audio Analog Stereo\" | grep -oE \"[0-9]+\" | head -1); if [ -n \"$id\" ]; then sleep 2; wpctl set-volume \"$id\" 1.5; exit 0; fi; sleep 1; done; exit 1'";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # fish is enabled by illogical-flake's dotfiles module; that makes
  # home-manager also manage ~/.config/fish/config.fish, which collides with
  # the illogical-flake copy and aborts the login-time home-manager
  # activation ("would be clobbered"), so overrides never apply after a
  # reboot. We use zsh, so disable it.
  programs.illogical-impulse = {
    enable = true;
    dotfiles.fish.enable = false;
  };

  programs.kitty = {
    enable = true;
    settings = {
      shell = "${pkgs.zsh}/bin/zsh";
      allow_remote_control = "yes";
      confirm_os_window_close = 0;
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.45";
      cursor_trail_start_threshold = 2;
      background_opacity = "0.75"; # lower = more transparent
      dynamic_background_opacity = "yes";
    };
    extraConfig = ''
      include ~/.local/state/quickshell/user/generated/terminal/kitty-theme.conf
    '';
  };

  xdg.configFile."kitty/kitty.conf".force = true;

  xdg.configFile."rofi/config.rasi" = {
    force = true;
    text = ''
      @theme "/home/cocofioren/.local/share/rofi/themes/rounded-green-dark.rasi"

      configuration {
        show-icons: true;
        icon-theme: "Papirus-Dark";
        drun-display-format: "{icon} {name}";
        display-drun: "Apps";
      }
    '';
  };

  home.file.".local/share/rofi/themes/rounded-green-dark.rasi" = {
    force = true;
    text = ''
      /* ROUNDED THEME FOR ROFI */
      /* Author: Newman Sanchez (https://github.com/newmanls) */

      * {
          bg0:    #212121A0;
          bg1:    #2A2A2A;
          bg2:    #3D3D3D80;
          bg3:    #4CAF50F2;
          fg0:    #E6E6E6;
          fg1:    #FFFFFF;
          fg2:    #969696;
          fg3:    #3D3D3D;
      }

      @import "template/rounded-template.rasi"
    '';
  };

  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  xdg.configFile."gtk-4.0/gtk.css" = {
    force = true;
    text = ''
      /* libadwaita named colors only — the stable theming API. */
      /* No private-widget/structural rules; libadwaita defaults handle the layout. */
      @define-color window_bg_color rgba(17,17,19,0.86);
      @define-color window_fg_color #dcdcdc;
      @define-color view_bg_color rgba(21,21,23,0.82);
      @define-color view_fg_color #dcdcdc;
      @define-color headerbar_bg_color rgba(24,24,27,0.75);
      @define-color headerbar_fg_color #e2e2e2;
      @define-color headerbar_backdrop_color rgba(17,17,19,0.72);
      @define-color headerbar_shade_color rgba(0,0,0,0.35);
      @define-color sidebar_bg_color rgba(13,13,15,0.82);
      @define-color sidebar_fg_color #bfc0c2;
      @define-color sidebar_backdrop_color rgba(13,13,15,0.8);
      @define-color popover_bg_color rgba(28,28,31,0.9);
      @define-color popover_fg_color #dcdcdc;
      @define-color card_bg_color rgba(24,24,27,0.72);
      @define-color card_fg_color #dcdcdc;
      @define-color dialog_bg_color rgba(24,24,27,0.9);
      @define-color dialog_fg_color #dcdcdc;
      @define-color border_color rgba(255,255,255,0.09);
      @define-color accent_bg_color #6b6b6b;
      @define-color accent_fg_color #ffffff;
    '';
  };

  gtk = {
    enable = true;
    gtk3 = {
      theme = {
        name = "Adwaita-dark";
      };
      iconTheme = {
        name = "Papirus-Dark";
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
    gtk4 = {
      iconTheme = {
        name = "Papirus-Dark";
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  xdg.configFile."qt6ct/qt6ct.conf" = {
    force = true;
    text = ''
      [Appearance]
      icon_theme=Papirus-Dark
      cursor_theme=pikachu-cursor
      cursor_size=32
    '';
  };

  home.file.".icons/pikachu-cursor" = {
    source = ./cursors/pikachu;
    recursive = true;
  };

  home.file.".local/bin/spotify-fad-toggle" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle Spotify's Full App Display (glass album-art player) from anywhere.
      # Focuses Spotify, sends its built-in Alt+F hotkey, then restores focus.

      if ! pgrep -f "share/spotify/spotify" >/dev/null 2>&1; then
        spotify >/dev/null 2>&1 & disown
        sleep 3
      fi

      hyprctl dispatch focuswindow "class:spotify" >/dev/null 2>&1
      sleep 0.4
      CLASS=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty' 2>/dev/null)
      if [[ "$CLASS" == "spotify" || "$CLASS" == "Spotify" ]]; then
        wtype -M alt -k f
      fi
      hyprctl dispatch focuscurrentorlast >/dev/null 2>&1
    '';
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
    XCURSOR_THEME = "pikachu-cursor";
    XCURSOR_SIZE = "32";
    OPENCODE_DISABLE_AUTOUPDATE = "true";
  };

  home.sessionPath = [
    "$HOME/.empryo/bin"
  ];

  programs.git = {
    enable = true;

    settings = {
      user.name = "colombefioren";
      user.email = "colomberakotonjanahary@gmail.com";

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      rerere.enabled = true;
    };
  };

  programs.fetch = {
    enable = true;
    labelColor = "cyan";
    speed = 1.0;
  };

  programs.spicetify =
    let
      spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.dribbblish // {
        additionalCss = ''
          /* ---- glassmorphism panels (mirror your kitty glass) ---- */
          .Root,
          .main-background,
          .main-container,
          .main-background-divider,
          .main-topBar-background,
          .now-playing-bar,
          .main-bar-column,
          .main-bar-content,
          .sidebar-container,
          .sidebar,
          .main-kva-window,
          .main-tabBar,
          .main-card,
          .main-cardMainActions,
          .main-actionable-item-grabArea,
          .main-listRow:hover,
          .main-listRow:active,
          .main-detailHeaderGradient,
          .page,
          .main-tile,
          .main-topBar-topbarViewport,
          .main-topBar-topbarContent,
          .main-topBar-topbarContentRight,
          .main-userWidget-box,
          .main-navBar,
          .main-navBarNav,
          .main-navLink,
          .main-globalNav-container,
          .main-albumArtCard,
          .main-albumArtCardDefault,
          .main-artistArtCard,
          .main-addButton,
          .main-nowPlayingBar,
          aside.main-alternativeModes,
          .lyrics-lyrics-background,
          .main-lyricsCinema-controls,
          #lyrics-backdrop,
          #lyrics-backdrop-container {
            background: rgba(18, 22, 28, 0.55) !important;
            backdrop-filter: blur(10px) saturate(120%) !important;
            -webkit-backdrop-filter: blur(10px) saturate(120%) !important;
          }
          /* ---- lyric backdrop: soft glass glow instead of flat black ---- */
          .lyrics-lyrics-background {
            background: radial-gradient(
                ellipse at 50% 18%,
                rgba(148, 151, 155, 0.28),
                rgba(148, 151, 155, 0.07) 52%,
                rgba(6, 7, 9, 0.6) 100%
              ) !important;
          }
          .lyrics-lyrics-background,
          .lyrics-lyrics-container {
            --lyrics-color-background: transparent !important;
          }
          .lyrics-lyrics-container {
            --lyrics-color-active: rgba(255, 255, 255, 0.96) !important;
            --lyrics-color-inactive: rgba(255, 255, 255, 0.42) !important;
            --lyrics-color-passed: rgba(255, 255, 255, 0.78) !important;
            --lyrics-color-messaging: rgba(255, 255, 255, 0.5) !important;
          }
          #lyrics-backdrop,
          #lyrics-backdrop-container {
            background: radial-gradient(
                ellipse at 50% 25%,
                rgba(148, 151, 155, 0.3),
                transparent 65%
              ), rgba(8, 9, 12, 0.5) !important;
            backdrop-filter: blur(40px) saturate(150%) !important;
            -webkit-backdrop-filter: blur(40px) saturate(150%) !important;
          }
          /* ---- card-like glass popups ---- */
          .main-topBar-topbarContentRight button:has(img),
          .main-userWidget-box[data-testid="user-widget-link"] {
            background: rgba(40, 52, 62, 0.85) !important;
            backdrop-filter: blur(12px) !important;
            -webkit-backdrop-filter: blur(12px) !important;
          }
          /* ---- unobtrusive dividers ---- */
          .main-background-divider {
            background: rgba(255, 255, 255, 0.06) !important;
          }
          .main-listRow-headerBackground {
            background: rgba(255, 255, 255, 0.03) !important;
          }
        '';
      };
      customColorScheme = {
        text = "E0E0E0";
        subtext = "ABABAB";
        main = "121216";
        sidebar = "1A1A1E";
        player = "17171B";
        card = "202024";
        shadow = "000000";
        selected-row = "3A3D42";
        button = "787C81";
        button-active = "989BA0";
        button-disabled = "464950";
        tab-active = "8C8F94";
        notification = "202024";
        notification-error = "C85A5A";
        misc = "D6D6D8";
        highlight = "C8CACC";
      };
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        fullAppDisplay
      ];
    };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
        accent-color = "gray";
        cursor-theme = "pikachu-cursor";
        cursor-size = 32;
      };
      "org/gnome/nautilus/preferences" = {
        click-policy = "single";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      for seq_file in ~/.cache/matugen/sequences ~/.cache/wal/sequences ~/.cache/wallust/sequences; do
        if [[ -f "$seq_file" ]]; then
          cat "$seq_file"
        fi
      done

      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,bold"

      if command -v fetch >/dev/null 2>&1 && [ -t 1 ] && [ -n "$WAYLAND_DISPLAY" ]; then
        fetch
      fi
    '';

    shellAliases = {
      btw = "echo i use hyprland btw";
      ls = "eza --icons";
      cat = "bat";
      nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old && sudo nix-collect-garbage -d && sudo nixos-rebuild switch --flake /etc/nixos#dellillah";
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#dellillah";
      nbuild = "sudo nixos-rebuild dry-build --flake /etc/nixos#dellillah";
      nupdate = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake /etc/nixos#dellillah && git add flake.lock && git commit -m 'chore: update flake.lock' && git push";
      empryo = "~/.empryo/bin/empryo";
      end4pull = "cd ~/.config/quickshell/end4-pC && git pull";
      wvid = "$HOME/.config/quickshell/end4-pC/scripts/colors/switchwall.sh --mode dark $HOME/Downloads/wallpaper.mp4 >/dev/null 2>&1";
      wpic = "$HOME/.config/quickshell/end4-pC/scripts/colors/switchwall.sh --mode dark $HOME/Downloads/pokemon.png >/dev/null 2>&1";
      hunyuan = "cd ~/AI/Hunyuan3D-2.1 && nix-shell --run 'source ~/.venv-hunyuan/bin/activate && python gradio_app.py --model_path tencent/Hunyuan3D-2.1 --subfolder hunyuan3d-dit-v2-1'";
    };

    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec start-hyprland
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    btop
    yazi
    fish
    lazygit
    fastfetch
    fzf
    zoxide
    nautilus
    cmatrix

    git
    gh
    git-lfs

    neovim
    tree-sitter
    gnumake
    cmake
    pkg-config
    unzip
    zip
    wget
    curl

    clang
    clang-tools
    lldb
    gdb
    ninja

    uv

    jdk17
    maven
    gradle

    nodejs
    typescript
    typescript-language-server
    bun

    go
    rustc
    cargo
    ruby
    perl

    alejandra
    nixfmt-rfc-style
    stylua
    shfmt
    shellcheck

    jq
    yq
    just
    direnv
    nix-direnv
    semgrep

    wl-clipboard
    cliphist
    wtype

    brave
    vscode
    mpvpaper
    mpv

    google-chrome
    firefox
    vivaldi
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    loupe
    evince
    celluloid
    obs-studio

    spicetify-cli

    pavucontrol
    playerctl
    brightnessctl
    blueman

    adwaita-icon-theme
    hicolor-icon-theme
    papirus-icon-theme
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];

      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];

      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];

      "application/pdf" = [ "org.gnome.Evince.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
}
