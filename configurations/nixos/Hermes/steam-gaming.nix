{pkgs, ...}: {
  programs.steam-asahi = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true; # Steam bootstrap (steam-unwrapped)

  # muvm is rootless but needs /dev/kvm (root:kvm 0660 on NixOS).
  users.users.gaspard.extraGroups = ["kvm"];
  users.users.emma.extraGroups = ["kvm"];

  # Audio reaches the microVM through the PipeWire PulseAudio socket
  # (the launcher sets PULSE_SERVER=unix:/run/user/$uid/pulse/native).
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pciutils # lspci
    pulseaudio # pactl
    zenity
  ];

  # ---- Memory tier: THE piece stock NixOS is missing vs Fedora Asahi ----
  # Fedora Asahi Remix ships zswap + a 12 GiB swapfile BY DEFAULT (it moved off
  # zram-only because that caused premature OOM on 8/16 GiB Apple Silicon).
  # Stock NixOS ships no swap at all: Steam (~6 GiB) + Proton/DXVK + the FEX JIT
  # code cache then hit the OOM killer — that, plus a duplicated container
  # userland, is what made the Docker guide "unplayable". Mirror Fedora:
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 12 * 1024; # MiB
    }
  ];
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.zpool=zsmalloc"
    "zswap.max_pool_percent=20"
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
    "vm.watermark_scale_factor" = 125; # reclaim earlier, avoid latency cliffs
    "vm.max_map_count" = 1048576; # Proton/DXVK requirement (Fedora/Arch default)
  };
}
