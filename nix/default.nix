{
  lib,
  check-jsonschema,
  python3,
  tmuxPlugins,
  version,
  ...
}:
tmuxPlugins.mkTmuxPlugin {
  inherit version;
  pluginName = "tmux-which-key";
  propagatedBuildInputs = [
    check-jsonschema
    (python3.withPackages (ps: with ps; [ pyyaml ]))
  ];
  src = lib.cleanSource ../.;
  rtpFilePath = "plugin.sh.tmux";
}
