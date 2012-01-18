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
define kbp_drbd($location, $fstype=false, $mastermaster=true, $time_out=false, $connect_int=false, $ping_int=false, $ping_timeout=false, $after_sb_0pri="discard-younger-primary",
    $after_sb_1pri="discard-secondary", $after_sb_2pri="call-pri-lost-after-sb", $rate="5M", $verify_alg="md5") {
  if $mastermaster {
    class { "kbp_ocfs2":
      ocfs2_tag => $name;
    }
  }

  if ! $mastermaster and ! $fstype {
    fail { "fstype must be specified when not in mastermaster":; }
  }

  gen_drbd { $name:
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
    saddr    => $fqdn,
    proto    => "tcp",
    dport    => 7789,
    action   => "ACCEPT",
    exported => true,
    tag      => "ferm_drbd_${environment}_${name}";
  }

  mount { $location:
    ensure   => mounted,
    device   => "/dev/drbd1",
    fstype   => $mastermaster ? {
      true    => "ocfs2",
      default => $fstype,
    },
    options  => "nodev,nosuid,noatime",
    dump     => "0",
    pass     => "0",
    remounts => true,
    target   => "/etc/fstab",
  }

  kfile { "${location}/.monitoring":
    content => "DRBD_mount_ok",
    require => Mount[$location];
  }

  kbp_monitoring::drbd { $location:; }
}
