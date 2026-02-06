{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    ...
  }:
    let
        hosts = builtins.readDir ./hosts;
      in {
        nixosConfigurations = builtins.listToAttrs (
          map
          (host: {
            name = host;
            value = nixpkgs.lib.nixosSystem {
              specialArgs = { inherit host; };
              system = "x86_64-linux";
              modules = [
                ./common.nix
                ./hosts/${host}/configuration.nix
              ];
            };
          })
          (builtins.attrNames hosts)
        );
      };
}
