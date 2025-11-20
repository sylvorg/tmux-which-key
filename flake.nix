{
  description = "A plugin for tmux that allows users to select actions from a customizable popup menu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      toplevel@{ withSystem, ... }:
      {
        imports = [
          # To import a flake module
          # 1. Add foo to inputs
          # 2. Add foo as a parameter to the outputs function
          # 3. Add here: foo.flakeModule
        ];

        debug = true; # This exposes declarations for nixd lsp

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        perSystem =
          {
            config,
            self',
            inputs',
            pkgs,
            system,
            ...
          }:
          {
            packages.tmux-which-key =
              with pkgs;
              tmuxPlugins.mkTmuxPlugin {
                pluginName = "tmux-which-key";
                version = "dev";
                src = lib.cleanSource ./.;
                rtpFilePath = "plugin.sh.tmux";

                propagatedBuildInputs = [
                  check-jsonschema
                  (python3.withPackages (ps: with ps; [ pyyaml ]))
                ];

                postInstall = # bash
                  ''
                    find $target -type f -name '*.sh' -exec chmod +x {} \;
                    find $target -type f -name '*.tmux' -exec chmod +wx {} \;
                  '';
              };

            packages.default = self'.packages.tmux-which-key;
          };

        flake = {
          # The usual flake attributes can be defined here, including system-
          # agnostic ones like nixosModule and system-enumerating ones, although
          # those are more easily expressed in perSystem.
          homeManagerModules = rec {
            default = import ./nix/home-manager.nix;
            tmux-which-key = default;
          };
        };
      }
    );
}
