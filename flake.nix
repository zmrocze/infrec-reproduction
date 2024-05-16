{
  description = "Infinite recursion error reproduction";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, lib, inputs, ... }:
      {
        imports = [
          # defines pkgsConfig and pkgsFor, doesn't set any other module options
          ./modules/pkgs.nix
        ];
        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        pkgsConfig = {
          overlays = [
            # commenting out the below overlay avoids error
            (final: _: {
              mybash = final.bash;
            })
          ];
        };
        perSystem = { system, ... }:
          {
            # defining pkgsFor without the pkgs module shenanigans, instead in normal let bindings above, also avoids error
            packages.default = (config.pkgsFor system).hello;
            # packages.default = (pkgsFor system).hello;
          };
      });
}
