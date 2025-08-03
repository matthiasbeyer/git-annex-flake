{ git-annex-lib, ... }:

attrs@{
  name,
  attrName ? attrs.name,
  attrTimerName ? attrs.name,

  config,
  pkgs,
}:

let
  cfg = config.services."${attrName}";
  lib = pkgs.lib;
in
{
  options.services."${attrName}" =
    let
      mkBoolOption =
        default: description:
        lib.mkOption {
          inherit description default;
          example = !default;
          type = lib.types.bool;
        };
    in
    {
      enable = lib.mkEnableOption name;

      startAt = lib.mkOption {
        type = with lib.types; either str (nonEmptyListOf str);
        default = "daily";
        description = ''
          When or how often the backup should run.
          Must be in the format described in
          {manpage}`systemd.time(7)`.
          If you do not want the backup to start automatically, use `[ ]`.
          It will generate a systemd service borgbackup-job-NAME.
          You may trigger it manually via systemctl restart borgbackup-job-NAME.
        '';
      };

      persistentTimer = lib.mkOption {
        default = false;
        type = lib.types.bool;
        example = true;
        description = ''
          Set the `Persistent` option for the {manpage}`systemd.timer(5)`
          which triggers the backup immediately if the last trigger
          was missed (e.g. if the system was powered down).
        '';
      };

      inhibitsSleep = lib.mkOption {
        default = false;
        type = lib.types.bool;
        example = true;
        description = ''
          Prevents the system from sleeping while backing up.
        '';
      };

      path = lib.mkOption {
        description = ''
          Path of the git-annex repository to run git-annex-satisfy on.
        '';
        type = lib.types.path;

        example = "/home/alice/Pictures";
      };

      user = git-annex-lib.mkUserOption "git-annex-satisfy";
      group = git-annex-lib.mkGroupOption "git-annex-satisfy";

      package = lib.mkPackageOption pkgs "git-annex" { };

      remotes = lib.mkOption {
        description = "Do not operate on all remotes, but only on one";
        type = lib.types.nullOr (lib.types.nonEmptyListOf lib.types.str);
        default = null;
      };

      content-of = lib.mkOption {
        description = "Operate only on files in the specified path (inside the repository). By default, operates on all files in the working tree";
        type = lib.types.nullOr (lib.types.nonEmptyListOf lib.types.str);
        default = null;
      };

      all = mkBoolOption false ''
        Whether to call git-annex-fsck with --all
      '';

      common-options = git-annex-lib.mkCommonOptions "git-annex-fsck";
    };

  config.systemd.services."${attrName}" =
    let
      inhibitCallPrefix = git-annex-lib.mkInhibitCallPrefix "git-annex-satisfy" cfg;

      mkScript =
        cfg:
        let
          git-annex = "${lib.getExe cfg.package} satisfy";
          common-flags = git-annex-lib.common-options.commonOptionsToListOfStrings cfg;

          remotesArg = lib.optionalString (cfg.remotes) (lib.concatStringsSep " " cfg.remotes);

          flags = [
            (lib.optionalString (!isNull cfg.content-of) lib.concatStringsSep " " (
              lib.map (e: "--content-of=${e}") cfg.content-of
            ))
            (lib.optionalString (cfg.all) "--all")
            (git-annex-lib.processJobsOption cfg)
            (git-annex-lib.processJsonOption cfg)
            (git-annex-lib.processJsonErrorMessagesOption cfg)
          ] ++ common-flags;
        in
        "cd ${cfg.path} && ${git-annex} ${lib.concatStringsSep " " flags} ${remotesArg}";
    in
    lib.mkIf cfg.enable {
      description = "git-annex-satisfy service '${attrName}'";
      path = [ cfg.package ];
      script = "exec " + inhibitCallPrefix + (mkScript cfg);

      unitConfig = {
        RequiresMountFor = [ cfg.path ];
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
      };
    };
}
