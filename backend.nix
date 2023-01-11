{ system, nixpkgs, cargo2nix, ... }: {
  rust = {
    build = {
      src,
      rustChannel,
      rustVersion,
      cargo2nix_file,
      bin_name ? "backend",
      ... }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            cargo2nix.overlays.default
          ];
        };
        targets = pkgs.rustBuilder.makePackageSet {
          inherit rustChannel rustVersion;
          packageFun = import cargo2nix_file;
        };
      in
        (targets.workspace."${bin_name}" {}).bin;
  };
}
