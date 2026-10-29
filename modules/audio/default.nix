{ ... }:

{
  imports = [
    ./priority.nix
    ./earphone-balance.nix
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire-pulse."99-disable-flat-volumes" = {
      "pulse.properties" = {
        "pulse.flat-volumes" = false;
      };
    };
  };
}
