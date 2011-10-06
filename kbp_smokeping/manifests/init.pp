# Author: Kumina bv <support@kumina.nl>

# Class: kbp_smokeping::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_smokeping::server {
	include gen_smokeping::server

	Kbp_smokeping::Environment <<| |>>
	Ekfile <<| tag == "smokeping" |>>

	gen_smokeping::probe { "EchoPingHttp":
		package          => "echoping",
		binary           => "/usr/bin/echoping",
		forks            => 5,
		offset           => "50%",
		step             => 300,
		accept_redirects => "yes",
		ignore_cache     => "yes",
		ipversion        => 4,
		pings            => 5,
		port             => 80,
		priority         => 6,
		revalidate_data  => "no",
		timeout_value    => 3,
		tos              => "0xa0",
		url              => "/",
		waittime         => 1;
	}

	kfile { "/etc/smokeping/basepage.html":
		source => "kbp_smokeping/basepage.html";
	}
}

# Class: kbp_smokeping::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_smokeping::environment($owner="Kumina bv", $contact="support@kumina.nl", $url="smokeping.kumina.nl", $syslogfacility="local0") {
	gen_smokeping::environment { "${name}":
		owner          => $owner,
		contact        => $contact,
		cgiurl         => $name ? {
			"smokeping" => "http://${url}/cgi-bin/smokeping.cgi",
			default     => "http://${url}/cgi-bin/smokeping_${name}.cgi",
		},
		syslogfacility => $syslogfacility;
	}

	kbp_apache_new::vhost-addition { "${url}_80/smokeping_${name}.conf":
		content => template("kbp_smokeping/apache");
	}

	concat { "/etc/smokeping/config.d/${name}/.htpasswd":; }

	Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
		target => "/etc/smokeping/config.d/${name}/.htpasswd",
	}
}

# Define: kbp_smokeping::target
#
# Actions
#       Set up a target
#
# Depends:
#       gen_puppet
#
define kbp_smokeping::target($group=$::environment, $probe="EchoPingHttp", $path=false, $host=false, $subdir=$::environment) {
	gen_smokeping::target { "${name}":
		group  => $group,
		probe  => $probe,
		path   => $path ? {
			false   => undef,
			default => $path,
		},
		host   => $host ? {
			false   => undef,
			default => $host,
		},
		subdir => $subdir;
	}
}

# Define: kbp_smokeping::targetgroup
#
# Actions
#       Set up a target group
#
# Depends:
#       gen_puppet
#
define kbp_smokeping::targetgroup($remark=false, $subdir=$::environment) {
	gen_smokeping::targetgroup { "${name}":
		remark => $remark ? {
			false   => undef,
			default => $remark,
		},
		subdir => $subdir;
	}
}
