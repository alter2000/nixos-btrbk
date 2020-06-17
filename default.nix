{ lib, config, pkgs, ... }:

let
  cfg = config.services.btrbk;
  internalMount = "/mnt/raw";
  externalMount = "/mnt/backup";
in
with lib;
{
  options.services.btrbk = {
    enable = mkEnableOption "enable btrbk - a btrfs backup service";

    fileSystems = mkOption {
      # type = types.what?;
      description = "List of filesystems that need to be mounted for btrbk to run properly.";
      example = {
        "/mnt/from" = {
          neededForBoot = true;
          device = "/dev/disk/by-label/fsroot";
          options = [ "subvolid=5" "nofail" ];
        };
        "/mnt/external" = {
          neededForBoot = false;
          device = "/dev/disk/by-label/backup-hdd";
          options = [ "subvolid=5" "nofail" "x-systemd.device-timeout=15" ];
        };
      };
    };

    package = mkOption {
      type = types.package;
      default = pkgs.btrbk;
      example = pkgs.btrbk;
      description = "The package providing /bin/btrbk.";
    };

    configFile = mkOption {
      type = types.path;
      default = ./btrbk.conf;
      description = "The btrbk.conf file to use for this instance.";
    };
  };

  config = {
    inherit (cfg) fileSystems;

    environment.etc = {
      # TODO: parametrize
      "${baseNameOf cfg.configFile}".source = cfg.configFile;
    };

    systemd.services = {

      # TODO: parametrize
      btrbk-snapshot = {
        description = "btrbk snapshot + transfer service";
        preStart = "${cfg.package}/bin/btrbk clean -c ${baseNameOf cfg.configFile}";
        # postStart = "${pkgs.btrfs-progs}/bin/btrfs filesystem sync ${externalMount}";
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/btrbk -v -c ${cfg.configFile} run";
          Type = "oneshot";
        };
        startAt = "daily";
        unitConfig.RequiresMountsFor = [ "${externalMount}" ];
      };
    };
  };
}
