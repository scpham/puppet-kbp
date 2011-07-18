# Author: Kumina bv <support@kumina.nl>

# Class: kbp_munin::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::client inherits munin::client {
	kpackage { "libnet-snmp-perl":; }

	munin::client::plugin::config { "files_user_plugin":
		section => "files_user_*",
		content => "user root";
	}
}

# Class: kbp_munin::client::apache
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::client::apache {
	# This class is should be included in kbp_apache to collect apache data for munin
	include kbp_munin::client

	kpackage { "libwww-perl":; }

	kfile { "/etc/apache2/conf.d/server-status":
		content => template("kbp_munin/server-status"),
		notify  => Exec["reload-apache2"];
	}

	munin::client::plugin {
		"apache_accesses":;
		"apache_processes":;
		"apache_volume":;
	}
}

# Class: kbp_munin::client::puppetmaster
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::client::puppetmaster {
	include kbp_munin::client
	munin::client::plugin {
		"puppet_nodes":
			script_path => "/usr/local/share/munin/plugins",
			script      => "puppet_";
		"puppet_totals":
			script_path => "/usr/local/share/munin/plugins",
			script      => "puppet_";
	}

	munin::client::plugin::config { "puppet_":
		section => "puppet_*",
		content => "user root";
	}
}

# Class: kbp_munin::client::mysql
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::client::mysql {
	include kbp_munin::client
	if versioncmp($lsbdistrelease, 6) >= 0 {
		kpackage {"libcache-cache-perl":
			ensure => latest;
		}

		define munin_mysql {
			munin::client::plugin { "mysql_${name}":
				script => "mysql_";
			}
		}

		munin_mysql {["bin_relay_log","commands","connections",
			"files_tables","innodb_bpool","innodb_bpool_act",
			"innodb_insert_buf","innodb_io","innodb_io_pend",
			"innodb_log","innodb_rows","innodb_semaphores",
			"innodb_tnx","myisam_indexes","network_traffic",
			"qcache","qcache_mem","replication","select_types",
			"slow","sorts","table_locks","tmp_tables"]:;
		}
	} elsif versioncmp($lsbdistrelease, 6) < 0 {
		munin::client::plugin { ["mysql_bytes","mysql_innodb","mysql_queries","mysql_slowqueries","mysql_threads"]:;  }
	}
}

# Class: kbp_munin::client::nfs
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::client::nfs {
	include kbp_munin::client

	munin::client::plugin { "nfs_client":; }
}

# Class: kbp_munin::client::nfsd
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::client::nfsd {
	include kbp_munin::client

	munin::client::plugin { "nfsd":; }
}

# Class: kbp_munin::client::ntpd
#
# Actions:
#	Setup trending for ntpd.
#
# Depends:
#	kbp_munin::client
#	munin::client::plugin
#	gen_puppet
#
class kbp_munin::client::ntpd {
	include kbp_munin::client

	munin::client::plugin { ["ntp_kernel_err","ntp_kernel_pll_freq","ntp_kernel_pll_off","ntp_offset"]:; }
}

# Class: kbp_munin::client::bind9
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::client::bind9 {
	include kbp_munin::client

	munin::client::plugin { "bind9_rndc":; }

	munin::client::plugin::config { "bind9_rndc":
		content => "env.querystats /var/cache/bind/named.stats\nuser bind",
	}
}

# Define: kbp_munin::client::glassfish
#
# Actions:
#	Setup the munin trending for glassfish domains
#
# Depends:
#	kbp_munin::client
#	gen_puppet
#
define kbp_munin::client::glassfish ($jmxport) {
	include kbp_munin::client

	kbp_munin::client::jmxcheck {
		"${name}_${jmxport}_java_threads":;
		"${name}_${jmxport}_java_process_memory":;
		"${name}_${jmxport}_java_cpu":;
		"${name}_${jmxport}_gc_collectioncount":;
		"${name}_${jmxport}_gc_collectiontime":;
	}
}

# Define: kbp_munin::client::jmxcheck
#
# Actions:
#	install the link with the right name in /etc/munin/plugins using munin::client::plugin { }
#
# Depends:
#	gen_puppet
#	munin::client
#
define kbp_munin::client::jmxcheck {
	include gen_base::jmxquery

	munin::client::plugin { "jmx_${name}":
		script_path => "/usr/bin",
		script      => "jmx_",
		require     => Package["jmxquery"];
	}
}

# Class: kbp_munin::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_munin::server inherits munin::server {
	include kbp_nsca::client

	@@gen_ferm::rule { "Munin connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => "4949",
		action => "ACCEPT",
		tag    => "general";
	}

	Kfile["/etc/munin/munin.conf"] {
		source => "kbp_munin/server/munin.conf",
	}

	Kfile <| title == "/etc/send_nsca.cfg" |> {
		mode    => 640,
		group   => "munin",
	}

	kpackage { "rsync":; }

	# The RRD files for Munin are stored on a memory backed filesystem, so
	# sync it to disk on reboots.
	kfile { "/etc/init.d/munin-server":
		source => "munin/server/init.d/munin-server",
		mode => 755,
		require => [Package["rsync"], Package["munin"]],
	}

	service { "munin-server":
		enable => true,
		require => File["/etc/init.d/munin-server"],
	}

	exec { "/etc/init.d/munin-server start":
		unless => "/bin/sh -c '[ -d /dev/shm/munin ]'",
		require => Service["munin-server"];
	}

	# Cron job which syncs the RRD files to disk every 30 minutes.
	kfile { "/etc/cron.d/munin-sync":
		source => "munin/server/cron.d/munin-sync",
		require => [Package["munin"], Package["rsync"]];
	}
}
