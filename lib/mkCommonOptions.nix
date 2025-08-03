{ lib, ... }:

let
  mkBoolOption =
    default: description:
    lib.mkOption {
      inherit default description;
      example = !default;
      type = lib.types.bool;
    };
in

gitAnnexCall:
{
  force = mkBoolOption false "Pass --force to ${gitAnnexCall}";
  fast = mkBoolOption false "Pass --fast to ${gitAnnexCall}";
  quiet = mkBoolOption false "Pass --quiet to ${gitAnnexCall}";
  verbose = mkBoolOption false "Pass --verbose to ${gitAnnexCall}";
  explain = mkBoolOption false "Pass --explain to ${gitAnnexCall}";
  debug = mkBoolOption false "Pass --debug to ${gitAnnexCall}";
  no-debug = mkBoolOption false "Pass --no-debug to ${gitAnnexCall}";
  debugfilter = lib.mkOption {
    description = "Pass --debugfilter=name[,name..] to ${gitAnnexCall}";
    type = lib.types.nullOr (lib.types.listOf lib.types.str);
    default = null;
    example = [
      "Process"
      "External"
    ];
  };
  numcopies = lib.mkOption {
    description = "Pass --numcopies=N to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.int;
    default = null;
    example = 1;
  };

  mincopies = lib.mkOption {
    description = "Pass --mincopies=N to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.int;
    default = null;
    example = 1;
  };

  rebalance = mkBoolOption false "Pass --rebalance to ${gitAnnexCall}";

  time-limit = lib.mkOption {
    description = "Pass --time-limit=time to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "30m";
  };
  size-limit = lib.mkOption {
    description = "Pass --size-limit=size to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "50gb";
  };
  semitrust = lib.mkOption {
    description = "Pass --semitrust=repository to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "my-repo";
  };
  untrust = lib.mkOption {
    description = "Pass --untrust=repository to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "my-repo";
  };
  trust = lib.mkOption {
    description = "Pass --trust=repository to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "my-repo";
  };
  trust-glacier = mkBoolOption false "Pass --trust-glacier to ${gitAnnexCall}";
  user-agent = lib.mkOption {
    description = "Pass --user-agent=value to ${gitAnnexCall}";
    type = lib.types.nullOr lib.types.str;
    default = null;
  };
  notify-finish = mkBoolOption false "Pass --notify-finish to ${gitAnnexCall}";
  notify-start = mkBoolOption false "Pass --notify-start to ${gitAnnexCall}";
  config = lib.mkOption {
    description = "Pass a list of '-c name=value' to ${gitAnnexCall}";
    type = lib.types.nullOr (lib.types.nonEmptyListOf lib.types.str);
    default = null;
    example = [
      "foo=bar"
      "baz=baf"
    ];
  };
}
