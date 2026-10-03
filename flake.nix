{
  description = "Nix package for git-native-issue (git issue)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        git-native-issue = pkgs.callPackage ./package.nix { };
        default = git-native-issue;
      });

      overlays.default = final: _prev: {
        git-native-issue = final.callPackage ./package.nix { };
      };

      checks = forAllSystems (pkgs: {
        inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) git-native-issue;
      });
    };
}
