{ system, nixpkgs, ... }: let
  pkgs = import nixpkgs { inherit system; };

  build_yarn = type: { src, ... }: (pkgs.mkYarnPackage {
    name = "${type}_frontend";
    inherit src;
    builtInput = [ pkgs.yarn ];
    buildPhase = ''
      pushd deps/frontend
      yarn build
      popd
    '';
  }).overrideAttrs (oldAttrs: let
    pname = oldAttrs.pname;
  in
    {
      doDist = false;

      buildPhase = ''
        runHook preBuild
        shopt -s dotglob

        rm deps/${pname}/node_modules
        mkdir deps/${pname}/node_modules
        pushd deps/${pname}/node_modules
        ln -s ../../../node_modules/* .
        popd
        yarn --offline build
        runHook postBuild
      '';

      installPhase = let
        dirname = if type == "react"
          then "build" else
          if type == "vue" then "dist" else
          builtins.throw "Expected 'react' or 'vue', got ${type}";
      in ''
        runHook preInstall
        mv deps/${pname}/${dirname} $out
        runHook postInstall
      '';
    });
in {
  react.build = build_yarn "react";
  vue.build = build_yarn "vue";
}
