# flake part module for defining pkgs
{ config, lib, inputs, ... }: {
  options = with lib; {
    pkgsConfig = {
      systems = mkOption {
        type = with types; listOf str;
        default = config.systems;
        description = ''
          The systems to build pkgs for.
        '';
      };
      overlays = mkOption {
        description = "List of overlays.";
        default = [ ];
        type = types.raw; # important to avoid infinite recursion when merging option
      };
      nixpkgs = mkOption {
        description = "Nixpkgs flake input.";
        default = inputs.nixpkgs;
      };
      _allNixpkgs = mkOption {
        default = genAttrs config.pkgsConfig.systems (system: import config.pkgsConfig.nixpkgs { inherit system; inherit (config.pkgsConfig) overlays; });
        internal = true;
      };
    };
    pkgsFor = mkOption {
      description = "Function to generate pkgs set. Use the default value. Memorizes.";
      default = system: config.pkgsConfig._allNixpkgs.${system};
    };
  };

  config = {
    perSystem = { system, ... }:  {
      _module.args.pkgs = config.pkgsFor system;
    };
  };
}
