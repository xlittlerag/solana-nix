{
  stdenv,
  fetchFromGitHub,
}: let
  version = "2.3.10";
  sha256 = "sha256-ETwoMh1+bgFvIoo3Hih3HsR9RuK9YI/X3EHzCrnq8mg=";
in {
  inherit version;
  src = fetchFromGitHub {
    owner = "anza-xyz";
    repo = "agave";
    rev = "v${version}";
    fetchSubmodules = true;
    inherit sha256;
  };
}
