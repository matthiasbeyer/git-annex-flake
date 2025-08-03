{ git-annex-lib, ... }:

{ config, pkgs, ... }: git-annex-lib.mkFsckService {
  name = "git-annex-fsck";

  inherit config pkgs;
}
