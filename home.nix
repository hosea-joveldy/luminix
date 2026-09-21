{ config, pkgs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [ spicetify-nix.homeManagerModules.default ];

  home.username = "lumi";
  home.homeDirectory = "/home/lumi";
  home.stateVersion = "26.05";

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  home.shellAliases = {
    zed = "zeditor";
  };

  home.packages = with pkgs; [
    anki
    antigravity
    chromium
    libreoffice-qt
    obsidian
    ollama
    opencode
    syncthingtray
    zed-editor
    zoom-us

    #game
    mindustry-wayland
  ];

  programs.fastfetch =
    let
      c = {
        orange = "#D9703A"; # hat
        coral  = "#D4553F"; # body
        green  = "#86A873"; # leaves
        gold   = "#CCA86A"; # your original key color
        cream  = "#EBD3BC"; # light tones
        wood   = "#8A6A4A"; # balcony wood
      };

      esc = builtins.fromJSON ''"\u001b"'';
      swatch = r: g: b: "${esc}[48;2;${toString r};${toString g};${toString b}m  ${esc}[0m";
      palette = builtins.concatStringsSep " " [
        (swatch 217 112 58)   # orange
        (swatch 212 85 63)    # coral
        (swatch 134 168 115)  # green
        (swatch 204 168 106)  # gold
        (swatch 235 211 188)  # cream
        (swatch 138 106 74)   # wood
      ];
    in {
      enable = true;
      settings = {
        logo = {
          type = "kitty-direct";
          source = ./modules/fastfetch/stray.png;
          width = 25;
          height = 12;
          padding = { top = 1; right = 4; };
        };

        display = {
          separator = "  ";
          color = {
            keys = c.gold;
            title = c.orange;
            separator = c.wood;
            output = c.cream;
          };
          key = { type = "both"; width = 12; };
          percent = {
            type = [ "bar" "num" ];
            color = { green = c.green; yellow = c.gold; red = c.coral; };
          };
          bar = {
            width = 10;
            border = null;
            char = { elapsed = "▰"; total = "▱"; };
          };
        };

        modules = [
          "title"
          "separator"
          "os"
          "kernel"
          "uptime"
          "wm"
          "shell"
          "terminal"
          { type = "cpu"; format = "{name} ({cores-logical}T)"; }
          { type = "memory"; format = "{percentage-bar} {used} / {total}"; }
          {
            type = "disk";
            key = "Disk";
            folders = "/";
            format = "{size-percentage-bar} {size-used} / {size-total}";
          }
          "media"
          "break"
          { type = "custom"; format = palette; }
        ];
      };
    };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-terminal-emulator" = "kitty.desktop";
    };
  };

  xdg.dataFile."plasma/desktoptheme/Glassy".source = ./modules/plasma-theme/Glassy;
  xdg.dataFile."plasma/look-and-feel/GlassDark/contents/splash/Splash.qml".source = ./modules/splash/Splash.qml;
  xdg.dataFile."plasma/look-and-feel/GlassDark/contents/splash/images/nix-snowflake.svg".source = ./modules/splash/images/nix-snowflake.svg;
  xdg.dataFile."plasma/look-and-feel/GlassDark/metadata.json".source = ./modules/splash/metadata.json;

  xdg.configFile."fastfetch/zed.jsonc".text = builtins.toJSON {
    logo = {
      source = "nixos";
      padding = {
        right = 3;
      };
    };
    display = {
      size = {
        binaryPrefix = "jedec";
      };
    };
    modules = [
      "title"
      "break"
      "separator"
      "break"
      "os"
      "host"
      "kernel"
      "shell"
      "wm"
      "terminal"
      "cpu"
      "memory"
      "break"
      "colors"
    ];
  };

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.hazy // {
      additionalCss = ''
        .Root__top-container::before {
          display: none !important;
        }
      '';
    };
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
    ];
  };
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.65";
      confirm_os_window_close = 0;
      font_family = "JetBrains Nerd Font Mono";
      font_size = 13;
      window_padding_width = "32";
    };
    extraConfig = builtins.readFile ./modules/kitty-theme.conf;
  };

  programs.cava = {
    enable = true;
    settings = {
      general = {
        bars = 20;
        framerate = 60;
        sensitivity = 100;
      };
      input = {
        method = "pipewire";
      };
      output = {
        method = "ncurses";
      };
      color = {
        gradient = 1;
        gradient_count = 3;
        gradient_color_1 = "'#a7c080'";
        gradient_color_2 = "'#dbbc7f'";
        gradient_color_3 = "'#e67e80'";
      };
      smoothing = {
        noise_reduction = 50;
      };
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      if [ "$TERM_PROGRAM" = "zed" ]; then
        fastfetch -c zed
      else
        fastfetch
      fi
    '';
    shellAliases = {
      list-gens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nix-build = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };
  };

  programs.plasma = {
    enable = true;
    kwin = {
      effects = {
        blur.enable = true;
      };
    };
    workspace = {
      theme = "Glassy";
    };
  };

  programs.home-manager.enable = true;

 }
