{
  lib,
  flatpak,
  writeShellScriptBin,
  fetchurl,
  url,
  hash,
  version,
  ...
}:

let
  pname = "orion-browser";
  appId = "com.kagi.OrionGtk";

  flatpakBundle = fetchurl {
    inherit url hash;
    name = "orion-${version}.flatpak";
  };
in
writeShellScriptBin pname ''
  export PATH="${lib.makeBinPath [ flatpak ]}:$PATH"
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  if ! flatpak info --user ${appId} >/dev/null 2>&1; then
    flatpak update --user --noninteractive
    flatpak install --user --noninteractive --assumeyes ${flatpakBundle}
  fi
  export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
  exec flatpak run --user ${appId} "$@"
''
