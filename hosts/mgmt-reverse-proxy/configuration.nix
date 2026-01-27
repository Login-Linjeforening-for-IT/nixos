{config, pkgs, ...}:{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
  services.traefik = let
    domain = "login.no"; 
  in {
    enable = true;
    environmentFiles = [
      "/etc/traefik/digitalocean.env"
    ];
    staticConfigOptions = {
      entryPoints = {
        http = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "https";
            scheme = "https";
          };
        };

        https = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "postmaster@login.no";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge.provider = "digitalocean";
      };

      api.dashboard = true;
    };

    dynamicConfigOptions = {
      http.serversTransports.insecureTransport = {
        insecureSkipVerify = true;
      };
      http.routers = {
        "idrac1" = {
          service = "idrac1";
          entryPoints = [ "https" ];
          rule = "Host(`idrac1.${domain}`)";
        };
        "idrac2" = {
          service = "idrac2";
          entryPoints = [ "https" ];
          rule = "Host(`idrac2.${domain}`)";
        };
        "idrac3" = {
          service = "idrac3";
          entryPoints = [ "https" ];
          rule = "Host(`idrac3.${domain}`)";
        };
        "pve" = {
          service = "pve";
          entryPoints = [ "https" ];
          rule = "Host(`pve.${domain}`)";
        };
        "truenas" = {
          service = "truenas";
          entryPoints = [ "https" ];
          rule = "Host(`truenas.${domain}`)";
        };
      };
      http.services = {
        "idrac1" = {
          loadBalancer = {
            serversTransport = "insecureTransport";
            servers = [
            { url = "https://192.168.1.105"; }
          ];
          };
        };
        "idrac2" = {
          loadBalancer = {
            serversTransport = "insecureTransport";
            servers = [
              { url = "https://192.168.1.141"; }
            ];
          };
        };
        "idrac3" = {
          loadBalancer = {
            serversTransport = "insecureTransport";
            servers = [
              { url = "https://192.168.1.54"; }
            ];
          };
        };
        "pve" = {
          loadBalancer = {
            serversTransport = "insecureTransport";
            servers = [
              { url = "https://192.168.1.180:8006"; }
              { url = "https://192.168.1.134:8006"; }
            ];
            healthCheck = {
              path = "/";
              interval = "10s";
              timeout = "3s";
            };
          };
        };
        "truenas" = {
          loadBalancer = {
            serversTransport = "insecureTransport";
            servers = [
              { url = "https://192.168.1.107"; }
            ];
          };
        };
      };
    };
  };
}