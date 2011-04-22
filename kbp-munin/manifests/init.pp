class kbp-munin::client inherits munin::client {
	kpackage { "libnet-snmp-perl":; }

	munin::client::plugin::config { "files_user_plugin":
		section => "files_user_*",
		content => "user root";
	}
}

class kbp-munin::client::apache {
	# This class is should be included in kbp-apache to collect apache data for munin
	include kbp-munin::client

	kpackage { "libwww-perl":; }

	kfile { "/etc/apache2/conf.d/server-status":
		content => template("kbp-munin/server-status"),
		notify  => Exec["reload-apache2"];
	}

	munin::client::plugin {
		"apache_accesses":;
		"apache_processes":;
		"apache_volume":;
	}
}

class kbp-munin::client::puppetmaster {
    include kbp-munin::client
    munin::client::plugin {
        "puppet_nodes":
            script_path => "/usr/local/share/munin/plugins",
            script      => "puppet_";
        "puppet_totals":
            script_path => "/usr/local/share/munin/plugins",
            script      => "puppet_";
    }

    munin::client::plugin::config { "puppet_*":
        content => "user root";
    }
}

class kbp-munin::server inherits munin::server {
	include nagios::nsca

	Kfile["/etc/munin/munin.conf"] {
		source => "kbp-munin/server/munin.conf",
	}

	kfile { "/etc/send_nsca.cfg":
		source => "kbp-munin/server/send_nsca.cfg",
		mode => 640,
		group => "munin",
		require => Package["nsca"],
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
