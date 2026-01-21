{config, pkgs, ...}:{
  services.traefik = let
    domain = "login.no"; 
  in {
    enable = true;

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
        httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
    };

    dynamicConfigOptions = {
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
        "pve1" = {
          service = "pve1";
          entryPoints = [ "https" ];
          rule = "Host(`pve1.${domain}`)";
        };
        "pve2" = {
          service = "pve2";
          entryPoints = [ "https" ];
          rule = "Host(`pve2.${domain}`)";
        };
        "truenas" = {
          service = "truenas";
          entryPoints = [ "https" ];
          rule = "Host(`truenas.${domain}`)";
        };
      };
      http.services = {
        "idrac1" = {
          loadBalancer.servers = [
            { url = "https://192.168.1.105"; }
          ];
        };
        "idrac2" = {
          loadBalancer.servers = [
            { url = "https://192.168.1.141"; }
          ];
        };
        "idrac3" = {
          loadBalancer.servers = [
            { url = "https://192.168.1.54"; }
          ];
        };
        "pve1" = {
          loadBalancer.servers = [
            { url = "https://192.168.1.134:8006"; }
          ];
        };
        "pve2" = {
          loadBalancer.servers = [
            { url = "https://192.168.1.180:8006"; }
          ];
        };
        "truenas" = {
          loadBalancer.servers = [
            { url = "https://192.168.1.107"; }
          ];
        };
      };
    };
  };
}