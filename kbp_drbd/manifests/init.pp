# Author: Kumina bv <support@kumina.nl>

# Class: kbp_drbd
#
# Parameters:
#  otherhost
#    Undocumented
#  mount_options
#    Set specific mount options for the actual mount point. Defaults to nodev,nosuid,noatime,acl,nointr.
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_drbd($location, $mastermaster=true, $time_out=false, $connect_int=false, $ping_int=false, $ping_timeout=false, $after_sb_0pri="discard-younger-primary",
    $after_sb_1pri="discard-secondary", $after_sb_2pri="call-pri-lost-after-sb", $rate="5M", $verify_alg="md5", $use_ipaddress=$external_ipaddress, $device_name=$name,
    $mount_options='nodev,nosuid,noatime,acl,nointr',$disk_flushes=true,$max_buffers=false,$unplug_watermark=false,$sndbuf_size=false,$al_extents=false) {
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
      options  => $mount_options,
      dump     => "0",
      pass     => "0",
      remounts => true,
      target   => "/etc/fstab",
      require  => Gen_drbd[$name];
    }

    file {
      "${location}/.monitoring":
        content => "DRBD_mount_ok",
        require => Mount[$location];
      '/etc/init.d/mount_ocfs2':
        content => template('kbp_drbd/mount_ocfs2'),
        mode    => 755,
        notify  => Exec['setup mount ocfs2 script'];
    }

    exec { 'setup mount ocfs2 script':
      command     => '/sbin/insserv -d mount_ocfs2',
      refreshonly => true;
    }

    kbp_icinga::drbd { $location:; }
  }

  gen_drbd { $name:
    use_ipaddress    => $use_ipaddress,
    mastermaster     => $mastermaster,
    time_out         => $time_out,
    connect_int      => $connect_int,
    ping_int         => $ping_int,
    ping_timeout     => $ping_timeout,
    after_sb_0pri    => $after_sb_0pri,
    after_sb_1pri    => $after_sb_1pri,
    after_sb_2pri    => $after_sb_2pri,
    disk_flushes     => $disk_flushes,
    max_buffers      => $max_buffers,
    unplug_watermark => $unplug_watermark,
    sndbuf_size      => $sndbuf_size,
    al_extents       => $al_extents,
    rate             => $rate,
    verify_alg       => $verify_alg,
    device_name      => $device_name;
  }

  Kbp_ferm::Rule <<| tag == "ferm_drbd_${environment}_${name}" |>>

  kbp_ferm::rule { "DRBD connections from ${fqdn} for ${name}":
    saddr    => $use_ipaddress,
    proto    => "tcp",
    dport    => 7789,
    action   => "ACCEPT",
    exported => true,
    ferm_tag => "ferm_drbd_${environment}_${name}";
  }
}
