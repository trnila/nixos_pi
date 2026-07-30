{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.linux-voice-assistant;

  inherit (lib)
    elem
    escapeShellArgs
    getExe
    literalExpression
    mkOption
    mkEnableOption
    mkIf
    mkPackageOption
    optional
    optionals
    types
    ;
in

{
  options.services.linux-voice-assistant = with types; {
    enable = mkEnableOption "Linux Voice Assistant";
    package = mkPackageOption pkgs "linux-voice-assistant" { };
  };

  config = mkIf cfg.enable {
    systemd.services."linux-voice-assistant" = {
      description = "Linux Voice Assistant";
      after = [
        "network-online.target"
        "sound.target"
      ];
      wants = [
        "network-online.target"
        "sound.target"
      ];
      wantedBy = [
        "multi-user.target"
      ];
      environment.XDG_CONFIG_HOME = "/tmp";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/linux-voice-assistant --debug --mic-volume 100 --audio-input-channels 2 --mic-noise-suppression 3 --name voicepi --download-dir /tmp/test --preferences-file /tmp/pref.json";
        #DynamicUser = true;
      };
    };
  };
}
