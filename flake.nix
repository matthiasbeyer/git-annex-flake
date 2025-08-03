{
  description = "A flake to orchestrate git-annex stuff";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
  let
    nixpkgs = inputs.nixpkgs.legacyPackages."${system}";
    callPackage = nixpkgs.lib.callPackageWith (nixpkgs // {
      git-annex-lib = inputs.self.lib."${system}";
      inherit inputs system;
      inherit callPackage;
    });
  in {
    lib = callPackage ./lib {};

    nixosModules = inputs.nixpkgs.lib.pipe ./nixosModules [
      builtins.readDir
      builtins.attrNames
      (map (origname: {
        name = inputs.nixpkgs.lib.removeSuffix ".nix" origname;
        value = callPackage (./nixosModules + "/${origname}") {
          inherit inputs;
        };
      }))
      builtins.listToAttrs
    ];

    checks = inputs.nixpkgs.lib.pipe ./checks [
      builtins.readDir
      builtins.attrNames
      (map (origname: {
        name = inputs.nixpkgs.lib.removeSuffix ".nix" origname;
        value = callPackage (./checks + "/${origname}") {
          inherit inputs;
        };
      }))
      builtins.listToAttrs
    ];
  });
}
