# Nixos machines
This is a repo for Login's Nixos machines.
## Adding a new machine
1. Add a new folder in hosts. The name of the folder will be the hostname of the machine.
2. In the folder create a file called `configuration.nix`
3. Add the configuration in this file
## Building a macine
Run `nix build .#<foldername>`