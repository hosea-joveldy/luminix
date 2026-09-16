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
    chromium
    libreoffice
    obsidian
    ollama
    opencode
    syncthingtray
    zed-editor
    zoom-us
  ];

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
	type = "kitty";
        source = "/home/lumi/Pictures/ghibli-cropped.jpg";
        padding = {
          right = 3;
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
        "media"
        "break"
        "colors"
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
    theme = spicePkgs.themes.hazy;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
    ];
  };
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.80";
      confirm_os_window_close = 0;
      font_family = "JetBrains Nerd Font Mono";
      font_size = 13;
      window_padding_width = 24;
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
      colorScheme = "Klassy Dark";
      theme = "Glassy";
      widgetStyle = "Klassy";
    };

    configFile."kwinrc"."org.kde.kdecoration2"."library" = "org.kde.klassy";
    configFile."kwinrc"."org.kde.kdecoration2"."theme" = "Klassy";
  };

  programs.home-manager.enable = true;

 }
