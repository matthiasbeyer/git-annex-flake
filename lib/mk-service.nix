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
          Path of the git-annex repository to run fsck on.
        '';
        type = lib.types.path;

        example = "/home/alice/Pictures";
      };

      user = git-annex-lib.mkUserOption "git-annex-fsck";
      group = git-annex-lib.mkGroupOption "git-annex-fsck";

      package = lib.mkPackageOption pkgs "git-annex" {};

      from = lib.mkOption {
        description = "Call with --from=remote";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      fast = mkBoolOption false ''
        Whether to call git-annex-fsck with --fast
      '';

      incremental = mkBoolOption false ''
        Whether to call git-annex-fsck with --incremental
      '';

      more = mkBoolOption false ''
        Whether to call git-annex-fsck with --more
      '';

      incremental-schedule = lib.mkOption {
        description = ''
          Call git-annex-fsck with --incremental-schedule=time
        '';
        type = lib.types.nullOr lib.types.str;

        default = null;
        example = "30d";
      };

      numcopies = lib.mkOption {
        description = ''
          Call git-annex-fsck with --numcopies=N
        '';
        type = lib.types.nullOr lib.types.int;

        default = null;
        example = 1;
      };

      all = mkBoolOption false ''
        Whether to call git-annex-fsck with --all
      '';

      branch = lib.mkOption {
        description = ''
          Whether to call git-annex-fsck with --branch=ref
        '';

        type = lib.types.nullOr lib.types.str;

        default = null;
        example = "master";
      };

      unused = mkBoolOption false ''
        Whether to call git-annex-fsck with --unused
      '';

      key = lib.mkOption {
        description = ''
          Whether to call git-annex-fsck with --key=keyname
        '';

        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      jobs = git-annex-lib.mkJobsOption "git-annex-fsck";
      json = git-annex-lib.mkJsonOption "git-annex-fsck";
      json-error-messages = git-annex-lib.mkJsonErrorMessagesOption "git-annex-fsck";
      common-options = git-annex-lib.mkCommonOptions "git-annex-fsck";
    };

  config.systemd.services."${attrName}" =
    let
      mkInhibitsSleepCallPrefix =
        cfg:
        lib.optionalString cfg.inhibitsSleep ''
          ${pkgs.systemd}/bin/systemd-inhibit \
            --who="git-annex-fsck" \
            --what="sleep" \
            --why="FSCK run" \
        '';

      mkScript =
        cfg:
        let
          git-annex = "${lib.getExe cfg.package} fsck";
          common-flags = git-annex-lib.common-options.commonOptionsToListOfStrings cfg;

          flags = [
            (lib.optionalString (!isNull cfg.from) "--from=${cfg.from}")
            (lib.optionalString (cfg.fast) "--fast")
            (lib.optionalString (cfg.incremental) "--incremental")
            (lib.optionalString (cfg.more) "--more")
            (lib.optionalString (!isNull cfg.incremental-schedule) "--incremental-schedule=${cfg.incremental-schedule}")
            (lib.optionalString (!isNull cfg.numcopies) "--numcopies=${cfg.numcopies}")
            (lib.optionalString (cfg.all) "--all")
            (lib.optionalString (!isNull cfg.branch) "--numcopies=${cfg.branch}")
            (lib.optionalString (cfg.unused) "--unused")
            (lib.optionalString (!isNull cfg.key) "--numcopies=${cfg.key}")
            (git-annex-lib.processJobsOption cfg)
            (git-annex-lib.processJsonOption cfg)
            (git-annex-lib.processJsonErrorMessagesOption cfg)
          ] ++ common-flags;
        in "${git-annex} ${lib.concatStringsSep " " flags} ${cfg.path}";
    in
    lib.mkIf cfg.enable {
      description = "git-annex-fsck service '${attrName}'";
      path = [ cfg.package ];
      script = "exec " + (mkInhibitsSleepCallPrefix cfg) + (mkScript cfg);

      unitConfig = {
        RequiresMountFor = [ cfg.path ];
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
      };
    };

  config.systemd.timers."${attrTimerName}" = lib.mkIf cfg.enable {
    description = "Timer for git-annex-fsck service '${attrName}'";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Persistent = cfg.persistentTimer;
      OnCalendar = cfg.startAt;
    };

    # If running on remote repository, wait for network-online.target
    after = lib.optional (cfg.persistentTimer && (!isNull cfg.from)) "network-online.target";
    wants = lib.optional (cfg.persistentTimer && (!isNull cfg.from)) "network-online.target";
  };

  meta.maintainers = [ lib.maintainers.matthiasbeyer ];
}
