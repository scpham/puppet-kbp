# Author: Kumina bv <support@kumina.nl>

# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

# Class: kbp_pacemaker
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_pacemaker ($customtag="pacemaker_${environment}") {
  class { "gen_pacemaker":
    customtag => $customtag;
  }
  include kbp_monitoring::pacemaker
}

define kbp_pacemaker::primitive ($provider, $location=false, $location_score="inf", $location_name=false, $start_timeout=false, $monitor_interval=false,
    $monitor_timeout=false, $stop_timeout=false, $params=false, $group=false, $customtag="pacemaker_${environment}") {
  gen_pacemaker::primitive { "${name}":
    provider         => $provider,
    location         => $location,
    location_score   => $location_score,
    location_name    => $location_name,
    start_timeout    => $start_timeout,
    stop_timeout     => $stop_timeout,
    monitor_interval => $monitor_interval,
    monitor_timeout  => $monitor_timeout,
    group            => $group,
    params           => $params,
    customtag        => $customtag;
  }
}


define kbp_pacemaker::master_slave ($primitive, $meta, $customtag="pacemaker_${environment}") {
  gen_pacemaker::master_slave { "$name":
    primitive => $primitive,
    meta      => $meta,
    customtag => $customtag;
  }
}

define kbp_pacemaker::location ($primitive, $score="inf", $resnode, $customtag="pacemaker_${environment}") {
  gen_pacemaker::location { "${name}":
    primitive => $primitive,
    score     => $score,
    resnode   => $resnode,
    customtag => $customtag;
  }
}

define kbp_pacemaker::colocation ($resource_1, $resource_2, $score="inf", $customtag="pacemaker_${environment}") {
  gen_pacemaker::colocation { "${name}":
    resource_1 => $resource_1,
    resource_2 => $resource_2,
    score      => $score,
    customtag  => $customtag;
  }
}

define kbp_pacemaker::order ($score="inf", $resource_1, $resource_2, $customtag="pacemaker_${environment}") {
  gen_pacemaker::order { "${name}":
    resource_1 => $resource_1,
    resource_2 => $resource_2,
    score      => $score,
    customtag  => $customtag;
  }
}

define kbp_pacemaker::group ($customtag="pacemaker_${environment}") {
  gen_pacemaker::group { "${name}":
    customtag => $customtag;
  }
}

# Class: kbp_pacemaker::hetzner
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_pacemaker::hetzner {
  include kbp_pacemaker
  include hetzner::failover_ip

  fail("This class doesn't seem to be working")

  # Our custom ocf script
  file {
    "/usr/lib/ocf/resource.d/kumina/hetzner-failover-ip":
      ensure  => link,
      target  => "/usr/local/lib/hetzner/hetzner-failover-ip",
      require => File["/usr/local/lib/hetzner/hetzner-failover-ip"];
    "/usr/lib/ocf/resource.d/kumina":
      ensure => directory,
      require => Kpackage["pacemaker"];
    "/usr/lib/ocf/resource.d/kumina/update-dns":
      source => "pacemaker/update-dns",
      mode => 755;
  }

  define updatednsconfig($ipme, $ipother) {
    file { "${name}":
      content => template("kbp_pacemaker/update-dns.erb");
    }
  }
}
