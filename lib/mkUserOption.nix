{ lib, ... }:

gitAnnexCall: lib.mkOption {
  description = "User to call ${gitAnnexCall} with.";
  type = lib.types.str;
  default = "root";
}
