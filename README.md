# NixOS Configuration

This repository contains a flake-based NixOS configuration.

## Hosts

- NixOS release: `26.05`
- User: `vs`
- Shell: `zsh`

| Host | Hostname | Architecture | Target |
| --- | --- | --- | --- |
| `thinkpad-p14s` | `VSNixOSTP` | `x86_64-linux` | Lenovo ThinkPad P14s Gen 6, AMD Ryzen AI PRO 370, 64 GB RAM |
| `vmware-fusion` | `VSNixOSVM` | `aarch64-linux` | VMware Fusion VM on Apple silicon Mac |

## Structure

```text
|-- flake.nix
|-- flake.lock
|-- README.md
|-- INSTALL.md
|-- hosts
|   |-- thinkpad-p14s
|       |-- configuration.nix
|       |-- disko.nix
|       |-- hardware-configuration.nix
|   |-- vmware-fusion
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

Each host's `configuration.nix` defines its platform, hostname, default user,
default disk, and NixOS module. The top-level flake exposes each host as a
`nixosConfigurations` entry.

## Disk Layout

For `thinkpad-p14s`, Disko declares a single GPT disk:

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

For `vmware-fusion`, Disko uses the same GPT and btrfs subvolume layout without
LUKS encryption:

| Partition | Label | Format | Mount | Size |
| --- | --- | --- | --- | ---: |
| EFI system partition | `BOOT` | FAT32 | `/boot` | 1 GiB |
| Swap | `SWAP` | swap | swap device | 16 GiB |
| Root | `ROOT` | btrfs | `/` | remaining space |

## Routine Rebuild

After installation:

```sh
sudo nixos-rebuild switch --flake .#thinkpad-p14s
```

To check without switching:

```sh
nix flake check
sudo nixos-rebuild dry-build --flake .#thinkpad-p14s
```

For the VMware Fusion VM, use `.#vmware-fusion` instead.

See [INSTALL.md](./INSTALL.md) for the full installation procedure.
