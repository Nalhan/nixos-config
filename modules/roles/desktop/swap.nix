{
  # Fast, compressed swap is preferred. The disk-backed swapfile is a small
  # lower-priority safety net for incompressible memory pressure.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
      priority = 10;
    }
  ];
}
