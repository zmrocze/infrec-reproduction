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
        type = with types; listOf anything;
        default = [ ];
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
}
