{ callPackage, ... }:

{
  mkFsckService = callPackage ./mk-fsck-service.nix {};
  mkSatisfyService = callPackage ./mk-satisfy-service.nix {};

  mkUserOption = callPackage ./mkUserOption.nix {};
  mkGroupOption = callPackage ./mkGroupOption.nix {};

  mkJobsOption = callPackage ./mkJobsOption.nix {};
  processJobsOption = callPackage ./processJobsOption.nix {};

  mkJsonOption = callPackage ./mkJsonOption.nix {};
  processJsonOption = callPackage ./processJsonOption.nix {};

  mkJsonErrorMessagesOption = callPackage ./mkJsonErrorMessagesOption.nix {};
  mkCommonOptions = callPackage ./mkCommonOptions.nix {};

  common-options = callPackage ./processCommonOptions.nix {};
  processJsonErrorMessagesOption = callPackage ./processJsonErrorMessagesOption.nix {};

  mkInhibitCallPrefix = callPackage ./mkInhibitCallPrefix.nix {};
}
