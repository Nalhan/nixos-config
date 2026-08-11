{ pkgs }:

pkgs.writeShellApplication {
  name = "provision-age-identity";
  runtimeInputs = with pkgs; [
    _1password-cli
    coreutils
    gnugrep
    gum
    inetutils
    jq
    openssh
    ssh-to-age
  ];
  text = builtins.readFile ./provision-age-identity.sh;
}
