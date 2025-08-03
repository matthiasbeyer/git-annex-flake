{ git-annex-lib, ... }:

{ config, pkgs, ... }: git-annex-lib.mkSatisfyService {
  name = "git-annex-satisfy";

  inherit config pkgs;
}
