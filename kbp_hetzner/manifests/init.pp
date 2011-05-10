class kbp_hetzner inherits hetzner {
	include munin::client

	package { "lm-sensors":
		ensure => "latest";
	}

	munin::client::plugin { "sensors_temp":
		require => Package["lm-sensors"],
		script  => "sensors_",
		notify  => Exec["/sbin/modprobe f71882fg"];
	}

	exec { "/sbin/modprobe f71882fg":
		refreshonly => true;
	}

	line { "f71882fg": # Load the module on boot
		file    => "/etc/modules",
		ensure  => "present",
		content => "f71882fg";
	}

	ferm::new::rule {
		"Allow guests to connect to the internet":
			chain     => "FORWARD",
			interface => "ubr1",
			outerface => "ubr0",
			action    => "ACCEPT";
		"Allow the internet to connect to guests":
			chain     => "FORWARD",
			interface => "ubr0",
			outerface => "ubr1",
			action    => "ACCEPT";
	}
}
