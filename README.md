# luminix
![License](https://img.shields.io/github/license/hosea-joveldy/luminix)
![OS](https://img.shields.io/badge/OS-NixOS-5277C3)
![DE](https://img.shields.io/badge/DE-KDE%20Plasma%206-1D99F3)
![Repo Size](https://img.shields.io/github/repo-size/hosea-joveldy/luminix)

My personal NixOS config, built with flakes and Home Manager.

## What's inside
- [`configuration.nix`](./configuration.nix): System level config like bootloader, networking, DE, users, and system packages.
- [`hardware-configuration.nix`](./hardware-configuration.nix): Auto generated config for my machine, you probably shouldn't use mine and just run the scan command [below](#adjust-for-your-machine).
- [`flake.nix`](./flake.nix): Defines external links.
- [`home.nix`](./home.nix): User level config, software lives here, plus some packages that can only be installed through home manager.

## Requirements
1. **NixOS**: Obviously, but you could modify a few things and use this with just nix.
2. **Git**: To clone the repo.

## How to use this repo

### Clone the repo:

```bash
cd /etc/nixos
git clone https://github.com/hosea-joveldy/luminix.git
```

### Adjust for your machine:
1. Replace [`hardware-configuration.nix`](./hardware-configuration.nix) with the one generated on your own machine (`sudo nixos-generate-config`), since this file is tailored to your machine.
2. Update `networking.hostName` and the `users.users."lumi"` block in [`configuration.nix`](./configuration.nix) to match your setup.
3. Update `home.username` and `home.homeDirectory` in [`home.nix`](./home.nix).
4. If you use fastfetch, make sure to modify the image source, since the image itself isn't on your machine, and I use kitty which renders images on the terminal, your terminal might not support image rendering.

### Build it:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## License

This repo is licensed under the [MIT License](./LICENSE).
