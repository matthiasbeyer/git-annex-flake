{ git-annex-lib, ... }:

{ config, pkgs, ... }: git-annex-lib.mkService {
  name = "git-annex-fsck";

  inherit config pkgs;
}
