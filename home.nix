{ config, pkgs, inputs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username = "lumi";
  home.homeDirectory = "/home/lumi";
  home.stateVersion = "26.05";

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  home.shellAliases = {
    zed = "zeditor";
  };

  fonts.fontconfig.enable = true;

  home.packages = (with pkgs; [
    anki
    arduino-ide
    chromium
    libreoffice-qt
    obsidian
    syncthingtray
    thunderbird
    tor-browser
    zed-editor
    zoom-us

    # fonts
    nerd-fonts.jetbrains-mono
    eb-garamond
    libre-baskerville
    (google-fonts.override { fonts = [ "SpecialElite" "BebasNeue" ]; })

    #game
    mindustry-wayland

    # ai
    (llama-cpp.override { vulkanSupport = true; })
    vulkan-tools
  ]) ++ [
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli

    (pkgs.callPackage ./modules/lumitab/sign.nix { })
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-terminal-emulator" = "kitty.desktop";

      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";

      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "libreoffice-calc.desktop";
      "application/vnd.ms-excel" = "libreoffice-calc.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
      "text/csv" = "libreoffice-calc.desktop";

      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice-writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = "libreoffice-writer.desktop";
      "application/msword" = "libreoffice-writer.desktop";
      "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
      "application/rtf" = "libreoffice-writer.desktop";

      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "libreoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = "libreoffice-impress.desktop";
      "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
      "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";

      "application/vnd.oasis.opendocument.graphics" = "libreoffice-draw.desktop";
    };
  };

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
  xdg.configFile."hypr/hyprland.lua" = {
    source = ./modules/hyprland/hyprland.lua;
    force = true;
  };
  xdg.configFile."mimeapps.list".force = true;

  home.file.".config/mozilla/firefox/3eoiozxq.default-1789488385411/chrome/userChrome.css".force = true;
  home.file.".config/mozilla/firefox/3eoiozxq.default-1789488385411/chrome/userContent.css".force = true;

  xdg.dataFile."plasma/desktoptheme/Glassy".source = ./modules/plasma-theme/Glassy;
  xdg.dataFile."plasma/look-and-feel/GlassDark/contents/splash/Splash.qml".source = ./modules/splash/Splash.qml;
  xdg.dataFile."plasma/look-and-feel/GlassDark/contents/splash/images/nix-snowflake.svg".source = ./modules/splash/images/nix-snowflake.svg;
  xdg.dataFile."plasma/look-and-feel/GlassDark/metadata.json".source = ./modules/splash/metadata.json;


  programs.bash = {
    enable = true;
    bashrcExtra = ''
      if [ "$TERM_PROGRAM" = "zed" ]; then
        fastfetch -c zed
      else
        fastfetch
      fi

      export PATH="$HOME/.npm-global/bin:$PATH"
    '';
    shellAliases = {
      list-gens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nob = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };
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
          { type = "media"; key = "Playing"; format = "{title:-36}"; }
          { type = "media"; key = " "; format = "           {artist:-36}"; }
          "break"
          { type = "custom"; format = palette; }
        ];
      };
    };

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [
      (pkgs.callPackage ./modules/lumitab/native-host.nix { })
    ];
    profiles.default = {
      id = 0;
      isDefault = true;
      path = "3eoiozxq.default-1789488385411";

      extraConfig =
        builtins.readFile "${inputs.arkenfox-userjs}/user.js"
        + "\n"
        + builtins.readFile ./modules/firefox/user-overrides.js;

      userChrome = builtins.readFile ./modules/firefox/userChrome.css;
      userContent = builtins.readFile ./modules/firefox/userContent.css;
    };
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
      background_opacity = "0.65";
      confirm_os_window_close = 0;
      font_family = "JetBrains Nerd Font Mono";
      font_size = 13;
      window_padding_width = "32";
    };
    extraConfig = builtins.readFile ./modules/kitty-theme.conf;
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
