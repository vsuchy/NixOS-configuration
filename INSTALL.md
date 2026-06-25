# Installation Guide

This guide installs NixOS `26.05` from the NixOS minimal ISO.
It assumes UEFI boot and a single target disk.

## 1. Boot The Installer

Boot the NixOS minimal ISO in UEFI mode.

Confirm UEFI:

```sh
test -d /sys/firmware/efi && echo "UEFI boot confirmed"
```

## 2. Connect Wi-Fi

Interactive setup:

```sh
nmtui
```

Or use `nmcli`:

```sh
nmcli radio wifi on
nmcli device wifi list
nmcli device wifi connect "SSID" password "WIFI_PASSWORD"
```

Validate network access:

```sh
ping -c 3 cache.nixos.org
```

## 3. Become Root

```sh
sudo -i
```

Enable flakes for commands run from the installer shell:

```sh
export NIX_CONFIG="experimental-features = nix-command flakes"
```

## 4. Get This Repository

Clone the repository:

```sh
git clone https://github.com/vsuchy/NixOS-configuration.git /tmp/NixOS-configuration
cd /tmp/NixOS-configuration
```

## 5. Identify The Target Disk

List disks carefully:

```sh
lsblk -o NAME,SIZE,TYPE,MODEL,SERIAL,MOUNTPOINTS
ls -l /dev/disk/by-id/
```

Set the disk variable. This example is intentionally explicit:

```sh
export DISK=/dev/nvme0n1
```

Prefer a stable `/dev/disk/by-id/...` path when available:

```sh
export DISK=/dev/disk/by-id/nvme-REPLACE_WITH_THE_TARGET_DISK
```

Check one last time:

```sh
lsblk "$DISK"
```

## 6. Partition, Encrypt, Format, And Mount With Disko

The next command is destructive. It erases the selected disk.

Do not run it until `DISK` points to the correct target disk.

```sh
echo "$DISK"
lsblk "$DISK"
```

Run Disko from this repository's locked flake input:

```sh
nix run .#disko -- \
  --mode destroy,format,mount \
  ./hosts/VSThinkPad/disko.nix \
  --argstr disk "$DISK"
```

## 7. Generate Hardware Configuration

Generate the hardware configuration:

```sh
nixos-generate-config --root /mnt
```

Use the generated file:

```sh
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/VSThinkPad/hardware-configuration.nix
```

Important: Disko is the source of truth for filesystems, swap, LUKS mappings, and
resume configuration in this repository. Edit
`./hosts/VSThinkPad/hardware-configuration.nix` and remove generated
`fileSystems`, `swapDevices`, and duplicate `boot.initrd.luks.devices` entries
unless you intentionally reconcile them with `hosts/VSThinkPad/disko.nix`.

## 8. Install NixOS

Run a dry evaluation first:

```sh
nix flake check
nixos-rebuild dry-build --flake .#VSThinkPad
```

Install:

```sh
nixos-install --flake .#VSThinkPad
```

Set the root password when prompted.

Set the `vs` user password before rebooting:

```sh
nixos-enter --root /mnt -c 'passwd vs'
```

Copy the repository into the installed system:

```sh
mkdir -p /mnt/home/vs/Projects
cp -a /tmp/NixOS-configuration /mnt/home/vs/Projects/NixOS-configuration
nixos-enter --root /mnt -c 'chown -R vs:users /home/vs/Projects'
```

Reboot:

```sh
reboot
```
