# NixOS Configuration

This repository contains a flake-based NixOS configuration.

## Target Machine

- Architecture: `x86_64-linux`
- Hardware: Lenovo ThinkPad P14s Gen 6, AMD Ryzen AI PRO 370, 64 GB RAM
- NixOS release: `26.05`
- Hostname: `VSThinkPad`
- User: `vs`
- Shell: `zsh`

## Structure

```text
|-- flake.nix
|-- flake.lock
|-- README.md
|-- INSTALL.md
|-- hosts
|   |-- VSThinkPad
|       |-- configuration.nix
|       |-- disko.nix
|       |-- hardware-configuration.nix
|-- modules
|   |-- base.nix
|   |-- desktop.nix
|   |-- ...
|-- users
|   |-- vs
|       |-- home.nix
|-- dotfiles
    |-- ...
```

The host's `configuration.nix` defines its platform, hostname, default user,
default disk, and NixOS module. The top-level flake imports that host directly.

## Disk Layout

Disko declares a single GPT disk:

| Partition | Label | Format | Mount | Size |
| --- | --- | --- | --- | ---: |
| EFI system partition | `BOOT` | FAT32 | `/boot` | 1 GiB |
| Swap | `SWAP` | LUKS2 + swap | `/dev/mapper/cryptswap` | 90 GiB |
| Root | `ROOT` | LUKS2 + btrfs | `/` | remaining space |

The btrfs filesystem uses these subvolumes:

- `@` mounted at `/`
- `@home` mounted at `/home`
- `@snapshots` mounted at `/.snapshots`
- `@nix` mounted at `/nix`
- `@log` mounted at `/var/log`

## Routine Rebuild

After installation:

```sh
sudo nixos-rebuild switch --flake .#VSThinkPad
```

To check without switching:

```sh
nix flake check
sudo nixos-rebuild dry-build --flake .#VSThinkPad
```

See [INSTALL.md](./INSTALL.md) for the full installation procedure.
