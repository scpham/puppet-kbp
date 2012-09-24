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
class kbp_pacemaker {
  include kbp_icinga::pacemaker
  include gen_pacemaker
}

define kbp_pacemaker::primitive ($provider, $location=false, $location_score="inf", $location_name=false, $start_timeout=false, $monitor_interval=false, $monitor_timeout=false, $stop_timeout=false, $params=false, $group=false) {
  gen_pacemaker::primitive { $name:
    provider         => $provider,
    location         => $location,
    location_score   => $location_score,
    location_name    => $location_name,
    start_timeout    => $start_timeout,
    stop_timeout     => $stop_timeout,
    monitor_interval => $monitor_interval,
    monitor_timeout  => $monitor_timeout,
    group            => $group,
    params           => $params;
  }
}


define kbp_pacemaker::master_slave ($primitive, $meta) {
  gen_pacemaker::master_slave { $name:
    primitive => $primitive,
    meta      => $meta;
  }
}

define kbp_pacemaker::location ($primitive, $score="inf", $resnode) {
  gen_pacemaker::location { $name:
    primitive => $primitive,
    score     => $score,
    resnode   => $resnode;
  }
}

define kbp_pacemaker::colocation ($resource_1, $resource_2, $score="inf") {
  gen_pacemaker::colocation { $name:
    resource_1 => $resource_1,
    resource_2 => $resource_2,
    score      => $score;
  }
}

define kbp_pacemaker::order ($score="inf", $resource_1, $resource_2) {
  gen_pacemaker::order { $name:
    resource_1 => $resource_1,
    resource_2 => $resource_2,
    score      => $score;
  }
}

define kbp_pacemaker::group {
  gen_pacemaker::group { $name:; }
}
