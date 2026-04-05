# Orion Browser

This is my Orion Browser nix flake for Linux. This is just a flatpak wrapper for the official Orion Browser beta flatpak bundle.
> [!CAUTION]
> This is a very early beta of Orion Browser. Any bugs you find should be reported to the Orion team at: <br> [https://orionfeedback.org/t/desktop-linux](https://orionfeedback.org/t/desktop-linux).

> [!NOTE]
> Launching for the first time will take some time as the flatpak dependencies install. 

## Supported Architectures
- `x86_64-linux`
- `aarch64-linux`


## Installation
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    orion-browser.url = "github:dokokitsune/orion-browser-flake";
  };

  outputs = { nixpkgs, orion-browser, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ({ pkgs, ... }: {
          environment.systemPackages = [
            orion-browser.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```
