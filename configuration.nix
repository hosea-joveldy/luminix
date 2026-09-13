# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 20*1024;
  }];

  boot.resumeDevice = "/dev/disk/by-uuid/3a14cef4-5ba3-49e9-8667-86f1f8bea8fc";
  boot.kernelParams = [
    "resume_offset=35565568"
    "nvme_core.default_ps_max_latency_us=0"
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # Use the WirePlumber session manager
    #wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "hibernate";

  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  users.users."lumi" = {
    isNormalUser = true;
    description = "lumi";
    extraGroups = [ "networkmanager" "wheel" "docker" "input"];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    dnsutils
    docker-credential-helpers
    efibootmgr
    fusuma
    gnupg
    htop
    iw
    pass
    pulseaudio
    tree
    ydotool

    # ocr screenshot to text
    grim
    slurp
    tesseract
    wl-clipboard

    (writeShellScriptBin "ocr-screenshot" ''
      ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" -t png - | ${tesseract}/bin/tesseract - - 2>/dev/null | ${wl-clipboard}/bin/wl-copy
    '')

    # dev related
    git
    nodejs
    php
    phpPackages.composer
    python314
    uv
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  systemd.user.services.ydotoold = {
    description = "ydotool daemon";
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.ydotool}/bin/ydotoold";
  };

  systemd.user.services.fusuma = {
    description = "fusuma gesture daemon";
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.fusuma}/bin/fusuma";
  };

  services.pipewire.wireplumber.extraConfig."51-priority" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_output.pci-.*"; }
        ];
        actions = {
          update-props = {
            "priority.session" = 100;
          };
        };
      }
      {
        matches = [
          { "node.name" = "~alsa_output.usb-.*"; }
        ];
        actions = {
          update-props = {
            "priority.session" = 2000;
          };
        };
      }
    ];
    "monitor.bluez.rules" = [
      {
        matches = [
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          update-props = {
            "priority.session" = 3000;
          };
        };
      }
    ];
  };

  services.syncthing = {
    enable = true;
    user = "lumi";
    dataDir = "/home/lumi/.local/share/syncthing";
    configDir = "/home/lumi/.config/syncthing";
    openDefaultPorts = true;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
