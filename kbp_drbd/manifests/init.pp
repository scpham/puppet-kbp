# Author: Kumina bv <support@kumina.nl>

# Class: kbp_drbd
#
# Parameters:
#  otherhost
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_drbd($location, $mastermaster=true, $time_out=false, $connect_int=false, $ping_int=false, $ping_timeout=false, $after_sb_0pri="discard-younger-primary",
    $after_sb_1pri="discard-secondary", $after_sb_2pri="call-pri-lost-after-sb", $rate="5M", $verify_alg="md5", $use_ipaddress=$external_ipaddress) {
  include kbp_trending::drbd

  if $mastermaster {
    class { "kbp_ocfs2":
      use_ipaddress => $use_ipaddress,
      ocfs2_tag     => $name;
    }

    mount { $location:
      ensure   => mounted,
      device   => "/dev/drbd1",
      fstype   => "ocfs2",
      options  => "nodev,nosuid,noatime,acl",
      dump     => "0",
      pass     => "0",
      remounts => true,
      target   => "/etc/fstab",
      require  => Gen_drbd[$name];
    }

    file { "${location}/.monitoring":
      content => "DRBD_mount_ok",
      require => Mount[$location];
    }

    kbp_icinga::drbd { $location:; }
  }

  gen_drbd { $name:
    use_ipaddress => $use_ipaddress,
    mastermaster  => $mastermaster,
    time_out      => $time_out,
    connect_int   => $connect_int,
    ping_int      => $ping_int,
    ping_timeout  => $ping_timeout,
    after_sb_0pri => $after_sb_0pri,
    after_sb_1pri => $after_sb_1pri,
    after_sb_2pri => $after_sb_2pri,
    rate          => $rate,
    verify_alg    => $verify_alg;
  }

  Kbp_ferm::Rule <<| tag == "ferm_drbd_${environment}_${name}" |>>

  kbp_ferm::rule { "DRBD connections from ${fqdn} for ${name}":
    saddr    => $use_ipaddress,
    proto    => "tcp",
    dport    => 7789,
    action   => "ACCEPT",
    exported => true,
    tag      => "ferm_drbd_${environment}_${name}";
  }
}
