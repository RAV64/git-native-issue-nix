{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  installShellFiles,
  git,
  jq,
  coreutils,
  gnused,
  gnugrep,
  gawk,
  curl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "git-native-issue";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "remenoscodes";
    repo = "git-native-issue";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XVdv3awJGqIzGtOsIbuDndHl4biNfQnLsgzSkTe/j1c=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    make install install-doc prefix=$out
    installShellCompletion --cmd git-issue \
      --bash contrib/completion/git-issue.bash \
      --zsh contrib/completion/git-issue.zsh

    runHook postInstall
  '';

  # The scripts locate each other and source git-issue-lib through
  # "$(dirname "$0")", so wrapping keeps them side by side. The library is
  # sourced, never executed, and must stay a plain sh file.
  # gh and glab are deliberately left to the user's PATH: only the
  # GitHub/GitLab bridges need them, and they carry their own login state.
  postFixup = ''
    for script in $out/bin/git-issue*; do
      [ "$(basename "$script")" = git-issue-lib ] && continue
      wrapProgram "$script" --prefix PATH : ${
        lib.makeBinPath [
          git
          jq
          coreutils
          gnused
          gnugrep
          gawk
          curl
        ]
      }
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ git ];
  installCheckPhase = ''
    runHook preInstallCheck

    export HOME=$TMPDIR/home
    mkdir -p "$HOME"
    git config --global user.name "Nix Build"
    git config --global user.email "build@localhost"

    repo=$TMPDIR/repo
    git init -q "$repo"
    cd "$repo"
    export PATH=$out/bin:$PATH

    git issue version | grep -F "${finalAttrs.version}"
    id=$(git issue create "Install check" -m "Created by the Nix install check" -l test \
      | sed -n 's/^Created issue //p')
    test -n "$id"
    git issue comment "$id" -m "A comment"
    git issue state "$id" --close
    git issue ls --all | grep -F "Install check"
    git issue show "$id" | grep -F "A comment"
    git issue fsck

    runHook postInstallCheck
  '';

  meta = {
    description = "Distributed issue tracking embedded in Git";
    homepage = "https://github.com/remenoscodes/git-native-issue";
    changelog = "https://github.com/remenoscodes/git-native-issue/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    mainProgram = "git-issue";
    platforms = lib.platforms.unix;
  };
})
