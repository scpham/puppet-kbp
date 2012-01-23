# Author: Kumina bv <support@kumina.nl>

class kbp_physical::bonding {
  include gen_base::ifenslave-2_6

  kfile { "/etc/modprobe.d/bonding":
    content => template("kbp_physical/bonding");
  }
}

# Class: kbp_physical
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_physical {
  include kbp_kvm
  include kbp_libvirt
  include gen_base::bridge-utils
  include gen_base::vlan

  case $raidcontroller0_driver {
    "3w-9xxx": {
      kpackage { "3ware-cli-binary":; }

      kbp_monitoring::raidcontroller { "controller0":
        driver => "3ware";
      }
    }
    "aacraid": {
      kpackage { "arcconf":; }

      kbp_monitoring::raidcontroller { "controller0":
        driver => "adaptec";
      }
    }
  }

  if $consolefqdn != -1 {
    if ! $consolefqdn {
      fail("\$consolefqdn has not been set in the site.pp")
    }
    if ! $consoleaddress {
      fail("\$consoleaddress has not been set in the site.pp")
    }

    kbp_icinga::virtualhost { $consolefqdn:
      address            => $consoleaddress,
      parents            => $consoleparent,
      proxy              => $consoleproxy,
      allowproxyoverride => false;
    }

    if !$consoleipmi {
      kbp_monitoring::http { "http_${consolefqdn}":
        customfqdn         => $consolefqdn,
        proxy              => $consoleproxy,
        allowproxyoverride => false;
      }
    }
  }

  # Backup the MBR
  kfile { "/etc/backup/prepare.d/mbr":
    source  => "kbp_physical/mbr",
    mode    => 700,
    require => Package["backup-scripts"];
  }
}
