let
  btrfsOptions = [
    "compress=zstd"
    "noatime"
  ];
in

{
  disko.devices = {
    disk.main = {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          BOOT = {
            type = "EF00";
            label = "BOOT";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
              extraArgs = [
                "-F"
                "32"
                "-n"
                "BOOT"
              ];
            };
          };

          SWAP = {
            label = "SWAP";
            size = "16G";
            content = {
              type = "swap";
              extraArgs = [
                "-L"
                "SWAP"
              ];
            };
          };

          ROOT = {
            label = "ROOT";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "ROOT"
              ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = btrfsOptions;
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = btrfsOptions;
                };
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = btrfsOptions;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOptions;
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = btrfsOptions;
                };
              };
            };
          };
        };
      };
    };
  };
}
