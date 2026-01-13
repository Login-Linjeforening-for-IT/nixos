{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixos-generators,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        hosts = builtins.readDir ./hosts;
      in {
        packages = builtins.listToAttrs (
          builtins.map
          (host: {
            name = host;
            value = nixos-generators.nixosGenerate {
              system = system;
              modules = [
                {
                  services.openssh.enable = true;
                  services.qemuGuest.enable = true;
                  services.opkssh = rec {
                    enable = true;
                    providers = {
                      authentik = {
                        issuer = "https://authentik.login.no/application/o/jumpbox/";
                        clientId = "uV8fAROsKRWXEn09ovLRDA5Xa5GPZ7AX92isC3jl";
                      };
                    };
                    authorizations = [
                      {
                        user = "tekkom";
                        principal = "oidc:groups:TekKom";
                        inherit (providers.authentik) issuer;
                      }
                    ];
                  };
                  security.sudo.wheelNeedsPassword = false;
                  users.users.tekkom = {
                    isNormalUser = true;
                    extraGroups = ["wheel"];
                  };
                  nix.settings.trusted-users = [
                    "tekkom"
                  ];
                  system.stateVersion = "25.11";
                }
                (./hosts + "/${host}/configuration.nix")
              ];
              format = "qcow";
            };
          })
          (builtins.attrNames hosts)
        );
      }
    );
}
