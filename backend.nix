{ system, nixpkgs, cargo2nix, ... }: {
  rust = {
    build = {
      src,
      cargo2nix_file ? "${src}/Cargo.nix",
      bin_name ? "backend",
      rustBuilderArgs ? {},
    }: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          cargo2nix.overlays.default
        ];
      };
      targets = pkgs.rustBuilder.makePackageSet ({
        packageFun = import cargo2nix_file;
      } // rustBuilderArgs);
    in
      (targets.workspace."${bin_name}" {}).bin;
  };
}
