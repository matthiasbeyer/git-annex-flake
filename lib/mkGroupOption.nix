{ lib, ... }:

gitAnnexCall:

lib.mkOption {
  description = "Group to call ${gitAnnexCall} with.";
  type = lib.types.str;
  default = "root";
}
