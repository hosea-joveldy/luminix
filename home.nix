{ config, pkgs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};

  glassyKde = pkgs.fetchFromGitHub {
    owner = "Pr0cella";
    repo = "glassy-kde";
    rev = "master";
    sha256 = "sha256-IKzfN46bhCE2/xY7kGyKqrc0CCIjegylEmNVuhFQnNc=";
  };
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

    # rices
    papirus-icon-theme
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
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
      background_opacity = "0.55";
      background_blur = 20;
      confirm_os_window_close = 0;
      window_padding_width = 10;
      font_family = "JetBrains Nerd Font Mono";
      font_size = 13;
    };
    extraConfig = builtins.readFile ./modules/glass-dark.conf;
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
      colorScheme = "Glass Dark";
      theme = "Glassy";
      widgetStyle = "Glass";
    };
  };

  programs.home-manager.enable = true;

 }
