{ lib, ... }:

gitAnnexCall: lib.mkOption {
  description = "Pass --json to ${gitAnnexCall}";
  type = lib.types.bool;
  default = false;
  example = true;
}
