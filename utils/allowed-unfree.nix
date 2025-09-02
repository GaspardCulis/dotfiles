{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "cuda_sanitizer_api"
      "cuda_profiler_api"
      "cuda_cuobjdump"
      "cuda_cuxxfilt"
      "cuda_nvdisasm"
      "cuda_nvml_dev"
      "cuda_nvprune"
      "cuda_cudart"
      "cuda-merged"
      "cuda_cupti"
      "cuda_nvrtc"
      "cuda_cccl"
      "cuda_nvcc"
      "cuda_nvtx"
      "cuda_gdb"
      "libnpp"
      "libcufft"
      "libcublas"
      "libcurand"
      "libcusolver"
      "libcusparse"
      "libnvjitlink"
      # Steam
      "xow_dongle-firmware"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "steam-jupiter-unwrapped"
      "steamdeck-hw-theme"
      # Games
      "vintagestory"
    ];
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
  ];
}
