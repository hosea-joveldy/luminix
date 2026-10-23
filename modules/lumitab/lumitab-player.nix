{ pkgs }:

let
  launcher = pkgs.writeShellScript "lumitab-player-host" ''
    export PATH=${pkgs.lib.makeBinPath [ pkgs.playerctl ]}:$PATH
    exec ${pkgs.python3}/bin/python3 ${./lumitab_player_host.py}
  '';
in
pkgs.writeTextDir "lib/mozilla/native-messaging-hosts/lumitab_player.json" (
  builtins.toJSON {
    name = "lumitab_player";
    description = "Now-playing bridge for lumitab glass";
    path = "${launcher}";
    type = "stdio";
    allowed_extensions = [ "lumitab@glass" ];
  }
)
