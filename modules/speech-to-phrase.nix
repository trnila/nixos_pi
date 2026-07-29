{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.speech-to-phrase;

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
  options.services.speech-to-phrase = with types; {
    enable = mkEnableOption "Speech to Phrase";
    package = mkPackageOption pkgs "speech-to-phrase" { };
  };

  config = mkIf cfg.enable {
    systemd.services."speech-to-phrase" = {
      description = "Speech to Phrase";
      after = [
        "network-online.target"
      ];
      wants = [
        "network-online.target"
      ];
      wantedBy = [
        "multi-user.target"
      ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/speech-to-phrase";
        #DynamicUser = true;
      };
    };
  };
}
