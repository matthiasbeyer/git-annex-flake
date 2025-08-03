{ lib, ... }:

gitAnnexCall: lib.mkOption {
  description = "Pass --jobs=N to ${gitAnnexCall}";
  type = lib.types.nullOr lib.types.int;
  default = null;
  example = "2";
}
