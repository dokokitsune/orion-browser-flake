{
  lib,
  flatpak,
  symlinkJoin,
  writeShellScriptBin,
  makeDesktopItem,
  runCommand,
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
    name = "oriongtk-${version}.flatpak";
  };

  iconFile = fetchurl {
    url = "https://browser.kagi.com/press-kit/icon-main-logo.png";
    hash = "sha256-dINt5zkw2kCR7U3GvCGV0EBtqLWC7vg3H3LPeCbpwKI=";
  };

  iconDrv = runCommand "${pname}-icon" { } ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${iconFile} $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

binScript = writeShellScriptBin pname ''
  export PATH="${lib.makeBinPath [ flatpak ]}:$PATH"

  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  if ! flatpak info --user ${appId} >/dev/null 2>&1; then
    echo "Installing Orion Flatpak bundle..."
    flatpak install --user --noninteractive --assumeyes ${flatpakBundle}
  else
    current_version="$(flatpak info --user ${appId} 2>/dev/null | sed -n 's/^ *Version: *//p' | head -n1 || true)"

    if [ "$current_version" != "${version}" ]; then
      echo "Updating Orion Flatpak from $current_version to ${version}..."
      flatpak install --user --reinstall --noninteractive --assumeyes ${flatpakBundle}
    fi
  fi

  export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

  exec flatpak run --user ${appId} "$@"
'';

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Orion Browser";
    exec = "${binScript}/bin/${pname}";
    icon = pname;
    categories = [
      "Network"
      "WebBrowser"
    ];
  };
in
symlinkJoin {
  name = pname;
  paths = [
    binScript
    desktopItem
    iconDrv
  ];

  meta = {
    description = "Wrapper for the Orion Browser Flatpak";
    mainProgram = pname;
  };
}
