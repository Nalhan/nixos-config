{ pkgs, ... }:
{
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
    };
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.writeShellScriptBin "zen" "exec zen \"$@\""}/bin/zen";
    BROWSER = "zen";
  };

  home.packages = with pkgs; [
    grim
    slurp
  ];
}
