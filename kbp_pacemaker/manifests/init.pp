# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class kbp_pacemaker {
	include gen_pacemaker
	include kbp_pacemaker::monitoring::icinga

	define primitive ($provider, $location=false, $location_score="inf",
		$location_name=false,
		$start_interval=false, $start_timeout=false,
		$monitor_interval=false, $monitor_timeout=false,
		$stop_interval=false, $stop_timeout=false,
		$params=false) {
			gen_pacemaker::primitive { "${name}":
				provider         => $provider,
				location         => $location,
				location_score   => $location_score,
				location_name    => $location_name,
				start_interval   => $start_interval,
				start_timeout    => $start_timeout,
				stop_interval    => $stop_interval,
				stop_timeout     => $stop_timeout,
				monitor_interval => $monitor_interval,
				monitor_timeout  => $monitor_timeout,
				params           => $params;
			}
	}


	define master_slave ($primitive, $meta) {
		gen_pacemaker::master_slave { "$name":
			primitive => $primitive,
			meta      => $meta;
		}
	}
	define location ($primitive, $score="inf", $resnode) {
		gen_pacemaker::location { "${name}":
			primitive => $primitive,
			score     => $score,
			resnode   => $resnode;
		}
	}

	define colocation ($resource_1, $resource_2, $score="inf") {
		gen_pacemaker::colocation { "${name}":
			resource_1 => $resource_1,
			resource_2 => $resource_2,
			score      => $score;
		}
	}
	define order ($score="inf", $resource_1, $resource_2) {
		gen_pacemaker::order { "${name}":
			resource_1 => $resource_1,
			resource_2 => $resource_2,
			score      => $score;
		}
	}
	define group ($resources) {
		gen_pacemaker::group { "${name}":
			resources => $resources;
		}
	}
}

class kbp_pacemaker::monitoring::icinga {
	gen_icinga::service { "pacemaker_${fqdn}":
		service_description => "Pacemaker",
		checkcommand        => "check_pacemaker",
		nrpe                => true;
	}
}

class kbp_pacemaker::hetzner {
	include kbp_pacemaker
	include hetzner::failover_ip

	# Our custom ocf script
	kfile {
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
		kfile { "${name}":
			content => template("gen_pacemaker/update-dns.erb");
		}
	}
}
