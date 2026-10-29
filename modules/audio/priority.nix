{ ... }:

{
  services.pipewire.wireplumber.extraConfig."51-priority" = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "~alsa_output.pci-.*"; } ];
        actions.update-props."priority.session" = 100;
      }
      {
        matches = [ { "node.name" = "~alsa_output.usb-.*"; } ];
        actions.update-props."priority.session" = 2000;
      }
    ];
    "monitor.bluez.rules" = [
      {
        matches = [ { "node.name" = "~bluez_output.*"; } ];
        actions.update-props."priority.session" = 3000;
      }
    ];
  };
}
