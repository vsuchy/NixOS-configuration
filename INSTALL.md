# Installation Guide

This guide installs `thinkpad-p14s` with NixOS `26.05` from the NixOS minimal
ISO. It assumes UEFI boot, a TPM2 device, and a single target disk. Differences
for the QEMU/KVM and VMware Fusion guests are covered at the end.

## 1. Boot The Installer

Boot the NixOS minimal ISO in UEFI mode. Keep Secure Boot disabled while using
the installer because the standard NixOS installation image is not signed.
Leave TPM2 enabled.

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

The ThinkPad and VMware Fusion configurations declare `/dev/nvme0n1` as their
target disk; the QEMU/KVM configuration declares `/dev/vda`. If the target
disk has a different device path, update `disko.devices.disk.main.device` in the
selected host's `configuration.nix` before continuing.

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

Disko asks for LUKS passphrases for both `ROOT` and `SWAP`. Use strong values
and retain them as recovery credentials. TPM enrollment later adds keyslots; it
does not replace these passphrase slots.

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

## 8. Create Secure Boot Keys

Lanzaboote needs its signing keys while `nixos-install` installs the boot
loader. Generate them directly in the mounted target, not in the installer's
ephemeral `/var/lib`:

```sh
install -d -m 0700 /mnt/var/lib/sbctl
sbctl_config="$(mktemp)"
chmod 0600 "$sbctl_config"
printf '%s\n' 'keydir: /mnt/var/lib/sbctl/keys' 'guid: /mnt/var/lib/sbctl/GUID' > "$sbctl_config"
nix shell nixpkgs#sbctl --command sbctl --config "$sbctl_config" create-keys
rm -f "$sbctl_config"
unset sbctl_config
test -r /mnt/var/lib/sbctl/keys/db/db.key
```

The private keys remain under `/var/lib/sbctl` on the installed, encrypted
system. Make an encrypted offline backup after installation and never add them
to this repository.

## 9. Install NixOS

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

Keep Secure Boot disabled for this first boot. Unlock `ROOT` and `SWAP` with
their LUKS passphrases.

## Post-Installation

After rebooting, log in as `vs`. Run the commands below from the installed
system, using `sudo` where shown. The ThinkPad-only steps do not apply to either
VM. Account credentials, SSH keys, peripheral setup, and personal data require
manual provisioning in addition to the declarative configuration.

### 1. Connect To The Network

If the installed system is not already connected, configure its network through
Noctalia or NetworkManager. For Wi-Fi:

```sh
nmcli radio wifi on
nmcli device wifi list
nmcli --ask device wifi connect "SSID"
```

Confirm connectivity before authenticating any services:

```sh
ping -c 3 cache.nixos.org
```

### 2. Enroll Secure Boot Keys (ThinkPad Only)

First confirm that Lanzaboote signed the installed EFI images:

```sh
sudo sbctl status
sudo sbctl verify
```

Enter the ThinkPad firmware settings:

```sh
systemctl reboot --firmware-setup
```

In the firmware, open **Security > Secure Boot**, enable Secure Boot, and choose
**Reset to Setup Mode**. Do not choose **Clear All Secure Boot Keys**, because
that also removes the forbidden-signature database. Save the settings and boot
NixOS again, then enroll this machine's keys together with Microsoft's keys for
firmware and option-ROM compatibility:

```sh
sudo sbctl enroll-keys --microsoft
reboot
```

After rebooting, verify that enforcement is active and the boot files remain
signed:

```sh
bootctl status
sudo sbctl status
sudo sbctl verify
```

`bootctl status` should report `Secure Boot: enabled (user)` and TPM2 support.

### 3. Enroll TPM2 LUKS Unlocking (ThinkPad Only)

Enroll TPM tokens only after booting once with Secure Boot active, so the
managed PCR 7 measurements describe the enforced Secure Boot policy. Confirm
that the TPM supports `systemd-pcrlock` and that Lanzaboote generated a policy:

```sh
/run/current-system/systemd/lib/systemd/systemd-pcrlock is-supported
sudo test -s /var/lib/systemd/pcrlock.json && echo "PCR policy present"
```

The support check must print `yes`. Confirm that the `ROOT` and `SWAP`
partlabels identify the intended disk, then add an unattended TPM2 token to
each LUKS2 volume:

```sh
sudo systemd-cryptenroll \
  --tpm2-device=auto \
  --tpm2-pcrlock=/var/lib/systemd/pcrlock.json \
  /dev/disk/by-partlabel/ROOT

sudo systemd-cryptenroll \
  --tpm2-device=auto \
  --tpm2-pcrlock=/var/lib/systemd/pcrlock.json \
  /dev/disk/by-partlabel/SWAP
```

Each command asks for that volume's existing LUKS passphrase and adds a token;
it does not remove the passphrase.

Inspect the `Tokens` and `Keyslots` sections before rebooting:

```sh
sudo cryptsetup luksDump /dev/disk/by-partlabel/ROOT
sudo cryptsetup luksDump /dev/disk/by-partlabel/SWAP
reboot
```

Both mappings should now unlock through the TPM. If the measured state does not
match, the initrd asks for the retained LUKS passphrase. A normal
`nixos-rebuild` updates the `systemd-pcrlock` policy without re-enrolling the
volumes. After a TPM reset or when deliberately replacing a token, repeat the
corresponding enrollment command with `--wipe-slot=tpm2`; enrollment completes
before the old TPM slot is removed.

### 4. Back Up Recovery Material (ThinkPad Only)

Make an encrypted offline backup of `/var/lib/sbctl`, including its keys and
`GUID` file, and retain the recovery passphrases for both LUKS volumes. Keep the
backup outside this machine and outside this repository. Firmware, Secure Boot
key, or TPM changes can require the recovery passphrases on the next boot.

### 5. Authenticate Tailscale And Enable Mullvad (ThinkPad Only)

The configuration starts `tailscaled`, but joining the tailnet requires a
one-time interactive login:

```sh
sudo tailscale up
```

Open the printed URL, authenticate to the intended tailnet, and approve the
device in the Tailscale admin console if device approval is enabled.

The configured exit node is `sk-bts-wg-001.mullvad.ts.net`. Ensure the tailnet has
the Mullvad VPN add-on and this device has access to it through the admin console
or tailnet policy. See [Tailscale's Mullvad setup instructions](https://tailscale.com/docs/features/exit-nodes/mullvad-exit-nodes).

Once the exit node appears, apply the flags declared in
`modules/nixos/tailscale.nix` and check the connection:

```sh
tailscale exit-node list
sudo systemctl restart tailscaled-set.service
tailscale status
```

Confirm that `sk-bts-wg-001.mullvad.ts.net` is selected as the exit node. The
configuration also grants `vs` operator access and allows direct LAN access.
The settings service retries on failure, but retries cannot authenticate the
device or grant Mullvad access. If the configured exit node is unavailable,
choose an available node in `modules/nixos/tailscale.nix` and rebuild.

### 6. Set Up SSH Signing And GitHub Access

Git is configured to sign commits and tags with `~/.ssh/id_ed25519.pub`. Restore
the matching private and public keys from your backup, or generate a new pair if
neither file exists:

```sh
install -d -m 0700 ~/.ssh
ssh-keygen -t ed25519 -C "git@vsuchy.com" -f ~/.ssh/id_ed25519
```

Use a passphrase for the private key. After restoring or generating the pair,
set its permissions and load it into the graphical session's SSH agent:

```sh
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/id_ed25519
chmod 0644 ~/.ssh/id_ed25519.pub
ssh-add ~/.ssh/id_ed25519
```

Repeat `ssh-add` when the agent needs the key unlocked. Add the public key to
GitHub as a **Signing Key** so GitHub can verify signed commits and tags. For
SSH pushes, also register it as an **Authentication Key**; GitHub requires a
separate entry for each use. See [GitHub's SSH key instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

If using SSH for this repository, change the copied clone's HTTPS remote:

```sh
git -C ~/Projects/NixOS-configuration remote set-url origin git@github.com:vsuchy/NixOS-configuration.git
```

If retaining HTTPS, configure GitHub authentication for pushes separately.
Review and commit any host configuration edits made during installation once
signing is ready. Keep private keys outside the repository.

### 7. Authenticate Codex

Before using Codex, sign in as `vs` and complete the browser flow:

```sh
codex login
codex login status
```

For API-key authentication or a browserless login, follow the
[official OpenAI authentication documentation](https://learn.chatgpt.com/docs/auth).
Credentials are local user state and must not be committed to this repository.

### 8. Configure Peripherals And Restore Personal Data

Complete the steps relevant to the machine:

- On the ThinkPad, pair Bluetooth devices through Noctalia.
- For a printer, add a queue through [CUPS administration](http://localhost:631)
  and authenticate as `vs` when prompted. The configuration installs the
  `brlaser` driver but does not declare a printer queue.
- For external-monitor brightness on the ThinkPad, enable DDC/CI in the
  monitor's on-screen settings if necessary. Run `ddcutil detect` as `vs` from
  the graphical session to check detection and device access.
- Restore documents and application data from backup, open the existing
  Obsidian vault, and sign in to any optional services you use, such as Firefox
  Sync, Obsidian Sync, or private container registries.
- On the ThinkPad, create or import virtual machines through GNOME Boxes as
  needed. VM definitions and disk images are not provisioned by this flake.

### 9. Verify The Desktop Session

Noctalia starts automatically as a systemd user service when the graphical
session starts. Check it from a terminal in Niri:

```sh
systemctl --user status noctalia.service
```

Use Noctalia's **Lock & Suspend** action and confirm that the session requires
the `vs` password to unlock after resuming. If migrating from a configuration
that launched Noctalia directly from Niri, log out and back in after the first
rebuild so the existing process is replaced by the supervised service.

## Virtual Machine Notes

Both VM configurations use the same GPT and btrfs subvolume layout as
`thinkpad-p14s`, but without LUKS encryption and with a 16 GiB swap partition.
Neither imports Lanzaboote nor configures TPM unlocking, so skip the Secure Boot
key creation and the ThinkPad-only post-installation steps above.

| Configuration | Virtualization platform | NixOS ISO | Target disk | Guest integration |
| --- | --- | --- | --- | --- |
| `vm-qemu` | GNOME Boxes on the ThinkPad | `x86_64-linux` | `/dev/vda` | QEMU guest agent and SPICE |
| `vm-fusion` | VMware Fusion on an Apple silicon Mac | `aarch64-linux` | `/dev/nvme0n1` | VMware guest tools |

The disk paths in the table are defaults; identify the VM disk carefully and
update the selected host's `disko.devices.disk.main.device` value when its
device path differs.

Select the configuration for the VM being installed:

```sh
NIXOS_VM=vm-qemu
# NIXOS_VM=vm-fusion
```

Confirm its evaluated target before running the destructive Disko step:

```sh
NIXOS_VM_DISK="$(nix eval --raw ".#nixosConfigurations.${NIXOS_VM}.config.disko.devices.disk.main.device")"
lsblk "$NIXOS_VM_DISK"
```

Partition, format, and mount the selected VM disk:

```sh
nix run .#disko -- --mode destroy,format,mount --flake ".#${NIXOS_VM}"
```

Generate the VM hardware configuration:

```sh
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix "./hosts/${NIXOS_VM}/hardware-configuration.nix"
```

Disko owns filesystems and swap for both VM configurations. Edit the generated
`hardware-configuration.nix` and remove `fileSystems` and `swapDevices` unless
you intentionally reconcile them with `hosts/common/disko-vm.nix`.

Install the selected VM host:

```sh
nix flake check
nixos-rebuild dry-build --flake ".#${NIXOS_VM}"
nixos-install --flake ".#${NIXOS_VM}"
```

Before rebooting, set the root and `vs` passwords and copy the repository into
the installed system as described in [step 9](#9-install-nixos). After rebooting,
complete the applicable [post-installation steps](#post-installation).
