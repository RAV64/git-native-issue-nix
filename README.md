# git-native-issue-nix

Nix flake for [git-native-issue](https://github.com/remenoscodes/git-native-issue) (`git issue`).

## Install

```sh
nix profile add github:RAV64/git-native-issue-nix
```

## Overlay

```nix
inputs.git-native-issue-nix.url = "github:RAV64/git-native-issue-nix";

nixpkgs.overlays = [ inputs.git-native-issue-nix.overlays.default ];
environment.systemPackages = [ pkgs.git-native-issue ];
```

## Updating

Bump `version` in `package.nix`, set `hash = lib.fakeHash;`, run `nix build` and copy the hash it reports.
