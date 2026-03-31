{
  description = "Orian Browser flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        { system, pkgs, ... }:

        let
          sources = builtins.fromJSON (builtins.readFile ./sources.json);
          orion-browser = pkgs.callPackage ./orion-browser.nix {
            inherit (sources.${system}) hash url;
            inherit (sources) version;
          };
        in
        {
          packages = {
            default = orion-browser;
          };
          apps.default = {
            type = "app";
            program = "${orion-browser}/bin/orion-browser";
          };

        };
    };

}
