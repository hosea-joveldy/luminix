{ pkgs, ... }:

let
  usbSink = "alsa_output.usb-Generic_AB13X_USB_Audio_20210726905926-00.analog-stereo";
  rightMult = "0.1";

  pactl = "${pkgs.pulseaudio}/bin/pactl";

  conf = pkgs.writeText "earphone-balance.conf" ''
    context.modules = [
      { name = libpipewire-module-protocol-native }
      { name = libpipewire-module-client-node }
      { name = libpipewire-module-adapter }
      { name = libpipewire-module-filter-chain
        args = {
          node.description = "Earphone balanced"
          filter.graph = {
            nodes = [
              { type = builtin name = gainL label = linear control = { Mult = 1.0 Add = 0.0 } }
              { type = builtin name = gainR label = linear control = { Mult = ${rightMult} Add = 0.0 } }
            ]
            inputs = [ "gainL:In" "gainR:In" ]
            outputs = [ "gainL:Out" "gainR:Out" ]
          }
          audio.channels = 2
          audio.position = [ FL FR ]
          capture.props = {
            node.name = "balanced_earphone"
            media.class = "Audio/Sink"
          }
          playback.props = {
            node.name = "balanced_earphone_out"
            node.passive = true
            target.object = "${usbSink}"
          }
        }
      }
    ]
  '';

  makeDefault = pkgs.writeShellScript "earphone-balance-default" ''
    for i in $(seq 10); do
      if ${pactl} list short sinks | grep -q balanced_earphone; then
        ${pactl} set-default-sink balanced_earphone
        exit 0
      fi
      sleep 0.5
    done
  '';

  watch = pkgs.writeShellScript "earphone-balance-watch" ''
    check() {
      if ${pactl} list short sinks | grep -q "${usbSink}"; then
        systemctl --user start earphone-balance-filter.service
      else
        systemctl --user stop earphone-balance-filter.service
      fi
    }
    check
    ${pactl} subscribe | while read -r line; do
      case "$line" in *sink*) check ;; esac
    done
  '';
in
{
  systemd.user.services.earphone-balance-filter = {
    description = "Balance filter for the AB13X USB earphone";
    serviceConfig = {
      ExecStart = "${pkgs.pipewire}/bin/pipewire -c ${conf}";
      ExecStartPost = "${makeDefault}";
    };
  };

  systemd.user.services.earphone-balance-watch = {
    description = "Run the balance filter only while the earphone is plugged in";
    wantedBy = [ "default.target" ];
    after = [ "pipewire.service" "pipewire-pulse.service" "wireplumber.service" ];
    serviceConfig = {
      ExecStart = "${watch}";
      Restart = "on-failure";
    };
  };
}
