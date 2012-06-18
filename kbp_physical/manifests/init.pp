# Author: Kumina bv <support@kumina.nl>

class kbp_physical::bonding {
  include gen_base::ifenslave-2_6

  file { "/etc/modprobe.d/bonding.conf":
    content => template("kbp_physical/bonding");
  }

  file { "/etc/modprobe.d/bonding":
    ensure => absent;
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
  include gen_base::bridge-utils
  include gen_base::vlan

  kbp_libvirt { "kbp_libvirt":; }

  case $raidcontroller0_driver {
    "3w-9xxx": {
      package { "3ware-cli-binary":; }

      kbp_icinga::raidcontroller { "controller0":
        driver => "3ware";
      }
    }
    "aacraid": {
      package { "arcconf":; }

      kbp_icinga::raidcontroller { "controller0":
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
      address              => $consoleaddress,
      parents              => $consoleparent,
      proxy                => $consoleproxy,
      preventproxyoverride => true;
    }

    if !$consoleipmi {
      if ! $consolessl and ! $consolepath and ! $consolestatus {
        kbp_icinga::http { "http_${consolefqdn}":
          customfqdn           => $consolefqdn,
          proxy                => $consoleproxy,
          preventproxyoverride => true;
        }
      } else {
        kbp_icinga::site { "http_${consolefqdn}":
          customfqdn           => $consolefqdn,
          proxy                => $consoleproxy,
          ssl                  => $consolessl,
          path                 => $consolepath,
          statuscode           => $consolestatus,
          preventproxyoverride => true;
        }
      }
    }
  }

  # Backup the MBR
  file { "/etc/backup/prepare.d/mbr":
    content => template("kbp_physical/mbr"),
    mode    => 700,
    require => Package["backup-scripts"];
  }
}
