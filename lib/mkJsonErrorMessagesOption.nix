 { lib, ... }:

 gitAnnexCall: lib.mkOption {
  description = "Pass --json-error-messages to ${gitAnnexCall}";
  type = lib.types.bool;
  default = false;
  example = true;
}
