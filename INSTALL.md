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
```

Both host configurations declare `/dev/nvme0n1` as their target disk. If the
target disk has a different device path, update the `disk` value in the selected
host's `configuration.nix` before continuing.

Confirm the target disk declared by the ThinkPad configuration:

```sh
nix eval --raw .#nixosConfigurations.thinkpad-p14s.config.disko.devices.disk.main.device
lsblk "$(nix eval --raw .#nixosConfigurations.thinkpad-p14s.config.disko.devices.disk.main.device)"
```

## 6. Partition, Encrypt, Format, And Mount With Disko

The next command is destructive. It erases the disk declared by the selected
host configuration. Do not run it until that value points to the correct target
disk.

Run Disko from this repository's locked flake input:

```sh
nix run .#disko -- --mode destroy,format,mount --flake .#thinkpad-p14s
```

## 7. Generate Hardware Configuration

Generate the hardware configuration:

```sh
nixos-generate-config --root /mnt
```

Use the generated file:

```sh
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/thinkpad-p14s/hardware-configuration.nix
```

Important: Disko is the source of truth for filesystems, swap, LUKS mappings, and
resume configuration in this repository. Edit
`./hosts/thinkpad-p14s/hardware-configuration.nix` and remove generated
`fileSystems`, `swapDevices`, and duplicate `boot.initrd.luks.devices` entries
unless you intentionally reconcile them with `hosts/thinkpad-p14s/disko.nix`.

## 8. Install NixOS

Run a dry evaluation first:

```sh
nix flake check
nixos-rebuild dry-build --flake .#thinkpad-p14s
```

Install:

```sh
nixos-install --flake .#thinkpad-p14s
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

## VMware Fusion VM Notes

For `vmware-fusion` on a Mac with Apple silicon, use an `aarch64-linux` NixOS
ISO. This host uses Disko with the same btrfs subvolume layout as
`thinkpad-p14s`, but without LUKS encryption and with a 16 GiB swap partition.

Identify the VM disk carefully. The VM host configuration expects
`/dev/nvme0n1`. If necessary, update its `disk` value, then confirm the evaluated
target:

```sh
lsblk "$(nix eval --raw .#nixosConfigurations.vmware-fusion.config.disko.devices.disk.main.device)"
```

```sh
nix run .#disko -- --mode destroy,format,mount --flake .#vmware-fusion
```

Generate the VM hardware configuration:

```sh
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/vmware-fusion/hardware-configuration.nix
```

Disko owns filesystems and swap for `vmware-fusion`. Edit the generated
`./hosts/vmware-fusion/hardware-configuration.nix` and remove generated
`fileSystems` and `swapDevices` unless you intentionally reconcile them with
`hosts/vmware-fusion/disko.nix`.

Install the VM host with:

```sh
nix flake check
nixos-rebuild dry-build --flake .#vmware-fusion
nixos-install --flake .#vmware-fusion
```
