{ config, pkgs, ... }:

let
  btrcfg = ./btrbk.conf;
  basebcfg = baseNameOf btrcfg;
  btrbk = pkgs.btrbk;
  internalMount = "/mnt/raw";
  externalMount = "/mnt/backup";
in

{
  environment.etc = {
    # TODO: parametrize
    basebcfg.source = btrcfg;
  };

  fileSystems = {
    # TODO: parametrize
    # TODO: need to build attrset, not list

    "${internalMount}" = {
      device = "/dev/disk/by-label/lunix";
      neededForBoot = false;
      options = [ "subvolid=5" "nofail" "x-systemd.device-timeout=15" ];
    };

    "${externalMount}" = {
      device = "/dev/disk/by-label/bups";
      neededForBoot = false;
      options = [ "subvolid=5" "nofail" "x-systemd.device-timeout=15" ];
    };
  };

  systemd.services = {

    # TODO: parametrize
    btrbk-snapshot = {
      description = "btrbk snapshot + transfer service";
      preStart = "${btrbk}/bin/btrbk clean -c ${basebcfg}";
      postStart = "${pkgs.btrfs-progs}/bin/btrfs filesystem sync ${externalMount}";
      serviceConfig = {
        ExecStart = "${btrbk}/bin/btrbk -v -c ${basebcfg} run";
        Type = "oneshot";
      };
      startAt = "daily";
      unitConfig.RequiresMountsFor = [ "${externalMount}" ];
    };

  };
}
