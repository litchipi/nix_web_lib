{
  description = "Builds Web components with nix";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/22.11;
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust
    cargo2nix = {
      url = github:cargo2nix/cargo2nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system: let
    allargs = inputs // { inherit system; };
  in {
    lib = {
      frontend = import ./frontend.nix allargs;
      backend = import ./backend.nix allargs;
      database = import ./database.nix allargs;
    };
  });
}
