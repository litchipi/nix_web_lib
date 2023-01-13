{
  description = "Build nix_web_lib examples";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/22.11;
    flake-utils.url = github:numtide/flake-utils;
    nix_web_lib.url = path:..;
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
    lib = pkgs.lib;
    weblib = nix_web_lib.lib.${system};
  in rec {
    apps.build_all = let
      extract_drv = attrs: lib.attrsets.mapAttrsToList (name: value:
        if lib.attrsets.isDerivation value then value
        else if builtins.isAttrs value then extract_drv value
        else builtins.throw "Error when trying to extract derivation from ${name}"
        ) attrs;
      all_drv = lib.lists.flatten (extract_drv packages);
      exec = pkgs.writeShellScript "build_all_examples" (builtins.concatStringsSep "\n" (
        builtins.map (drv: "echo '${drv.name} builds normally, result: ${drv}'")
        all_drv
      ));
    in { type = "app"; program = "${exec}"; };

    packages.backend = {
      rust.actix-web = weblib.backend.rust.build {
        src = ./backend/rust/actix_web;
        bin_name = "actix_web";
        rustBuilderArgs.rustVersion = "1.61.0";
      };
    };

    packages.frontend = {
      react = weblib.frontend.react.build { src = ./frontend/react; };
      vue = weblib.frontend.vue.build { src = ./frontend/vue; };
    };
  });
}
