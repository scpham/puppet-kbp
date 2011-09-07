# Author: Kumina bv <support@kumina.nl>

# Class: kbp_monitoring::client::sslcert
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_monitoring::client::sslcert {
	gen_sudo::rule { "check_sslcert sudo rules":
		entity            => "nagios",
		as_user           => "root",
		password_required => false,
		command           => "/usr/lib/nagios/plugins/check_sslcert";
	}
}

# Class: kbp_monitoring::server
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_monitoring::server($package="icinga") {
	case $package {
		"icinga": { include kbp_icinga::server }
		"nagios": { include kbp_nagios::server }
	}

	@@gen_ferm::rule {
		"NRPE monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 5666,
			action => "ACCEPT",
			tag    => "general";
		"MySQL monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 3306,
			action => "ACCEPT",
			tag    => "mysql_monitoring";
		"Sphinxsearch monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 3312,
			action => "ACCEPT",
			tag    => "sphinxsearch_monitoring";
		"Cassandra monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => "(7000 8080 9160)",
			action => "ACCEPT",
			tag    => "cassandra_monitoring";
		"Glassfish monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 80,
			action => "ACCEPT",
			tag    => "glassfish_monitoring";
		"NFS monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "(tcp udp)",
			dport  => "(111 2049)",
			action => "ACCEPT",
			tag    => "nfs_monitoring";
		"DNS monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "udp",
			dport  => 53,
			action => "ACCEPT",
			tag    => "dns_monitoring";
	}
}

# Class: kbp_monitoring::environment
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_monitoring::environment($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::environment
		}
	}
}

# Class: kbp_monitoring::heartbeat
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_monitoring::heartbeat($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::heartbeat
		}
	}
}

# Class: kbp_monitoring::nfs::server
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_monitoring::nfs::server($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::nfs::server
		}
	}
}

# Class: kbp_monitoring::dhcp
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_monitoring::dhcp($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::dhcp
		}
	}
}

# Class: kbp_monitoring::cassandra
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_monitoring::cassandra($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::cassandra
		}
	}
}

# Class: kbp_monitoring::asterisk
#
# Parameters:
#	package
#		Defines the monitoring package to use
#
# Actions:
#	Set up asterisk monitoring
#
# Depends:
#	kbp_icinga
#
class kbp_monitoring::asterisk($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::asterisk
		}
	}
}

# Define: kbp_monitoring::sslcert
#
# Parameters:
#	package
#		Undocumented
#	path
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::sslcert($path, $package="icinga") {
	case $package {
		"icinga": {
			kbp_icinga::sslcert { "${name}":
				path => $path;
			}
		}
	}
}

# Define: kbp_monitoring::haproxy
#
# Parameters:
#	ha
#		Undocumented
#	url
#		Undocumented
#	response
#		Undocumented
#	package
#		Undocumented
#	address
#		Undocumented
#	max_check_attempts
#		Number of retries before the monitoring considers the site down.
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::haproxy($address, $port=false, $ha=false, $url=false, $response=false, $package="icinga", $max_check_attempts=false) {
	case $package {
		"icinga": {
			kbp_icinga::haproxy { "${name}":
				address            => $address,
				ha                 => $ha,
				url                => $url ? {
					false   => undef,
					default => $url,
				},
				port               => $port ? {
					false   => undef,
					default => $port,
				},
				max_check_attempts => $max_check_attempts,
				response           => $response ? {
					false   => undef,
					default => $response,
				};
			}
		}
	}
}

# Define: kbp_monitoring::java
#
# Parameters:
#	servicegroups
#		Undocumented
#	sms
#		Undocumented
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::java($package="icinga", $servicegroups=false, $sms=true) {
	case $package {
		"icinga": {
			kbp_icinga::java { "${name}":
				servicegroups => $servicegroups,
				sms           => $sms;
			}
		}
	}
}

# Define: kbp_monitoring::site
#
# Parameters:
#	address
#		Undocumented
#	conf_dir
#		Undocumented
#	false
#		Undocumented
#	parents
#		Undocumented
#	false
#		Undocumented
#	auth
#		Undocumented
#	package
#		Undocumented
#	max_check_attempts
#		For overriding the default max_check_attempts of the service.
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::site($package="icinga", $address=false, $conf_dir=$false, $parents=$false, $auth=false, $max_check_attempts=false, $path=false, $response=false, $vhost=true) {
	case $package {
		"icinga": {
			kbp_icinga::site { "${name}":
				address            => $address ? {
					false   => undef,
					default => $address,
				},
				conf_dir           => $conf_dir ? {
					false   => undef,
					default => $conf_dir,
				},
				parents            => $parents ? {
					false   => undef,
					default => $parents,
				},
				max_check_attempts => $max_check_attempts ? {
					false   => undef,
					default => $max_check_attempts,
				},
				auth               => $auth ? {
					false   => undef,
					default => $auth,
				},
				path               => $path ? {
					false   => undef,
					default => $path,
				},
				response           => $response ? {
					false   => undef,
					default => $response,
				},
				vhost              => $vhost ? {
					true    => undef,
					default => false,
				};
			}
		}
	}
}

# Define: kbp_monitoring::raidcontroller
#
# Parameters:
#	driver
#		Undocumented
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::raidcontroller($package="icinga", $driver) {
	case $package {
		"icinga": {
			kbp_icinga::raidcontroller { "${name}":
				driver => $driver;
			}
		}
	}
}

# Define: kbp_monitoring::http
#
# Parameters:
#	customfqdn
#		Undocumented
#	auth
#		Undocumented
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::http($package="icinga", $customfqdn=false, $auth=false) {
	case $package {
		"icinga": {
			kbp_icinga::http { "${name}":
				customfqdn => $customfqdn ? {
					false   => undef,
					default => $customfqdn,
				},
				auth       => $auth;
			}
		}
	}
}

# Define: kbp_monitoring::proc_status
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::proc_status($package="icinga") {
	case $package {
		"icinga": {
			kbp_icinga::proc_status { "${name}":; }
		}
	}
}

# Define: kbp_monitoring::sslsite
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::sslsite($package="icinga") {
	case $package {
		"icinga": {
			kbp_icinga::sslsite { "${name}":; }
		}
	}
}

# Define: kbp_monitoring::glassfish
#
# Parameters:
#	package
#		Undocumented
#	statuspath
#		Undocumented
#	webport
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::glassfish($webport, $package="icinga", $statuspath=false) {
	case $package {
		"icinga": {
			kbp_icinga::glassfish { "${name}":
				webport    => $webport,
				statuspath => $statuspath ? {
					false   => undef,
					default => $statuspath,
				};
			}
		}
	}
}

# Define: kbp_monitoring::mbean_value
#
# Parameters:
#	package
#		Undocumented
#	statuspath
#		Undocumented
#	jmxport
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::mbean_value($jmxport, $objectname, $attributename, $expectedvalue, $attributekey=false, $customname=false, $package="icinga") {
	case $package {
		"icinga": {
			kbp_icinga::mbean_value { "${name}":
				jmxport       => $jmxport,
				objectname    => $objectname,
				attributename => $attributename,
				expectedvalue => $expectedvalue,
				attributekey  => $attributekey ? {
					false   => undef,
					default => $attributekey,
				},
				customname    => $customname;
			}
		}
	}
}

# Define: kbp_monitoring::dnszone
#
# Parameters:
#	sms
#		Undocumented
#	package
#		Undocumented
#	master
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::dnszone($master, $sms=true, $package="icinga") {
	case $package {
		"icinga": {
			kbp_icinga::dnszone { "${name}":
				master => $master,
				sms    => $sms;
			}
		}
	}
}

# Define: kbp_monitoring::virtualhost
#
# Parameters:
#	conf_dir
#		Undocumented
#	parents
#		Undocumented
#	hostgroups
#		Undocumented
#	package
#		Undocumented
#	address
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_monitoring::virtualhost($address, $conf_dir=false, $parents=false, $hostgroups=false, $package="icinga", $sms=true, $notification_period=false) {
	case $package {
		"icinga": {
			kbp_icinga::virtualhost { "${name}":
				address               => $address,
				conf_dir              => $conf_dir ? {
					false   => undef,
					default => $conf_dir,
				},
				parents               => $parents ? {
					false   => undef,
					default => $parents,
				},
				hostgroups            => $hostgroups ? {
					false   => undef,
					default => $hostgroups,
				},
				sms                   => $sms,
				notification_period   => $notification_period ? {
					false   => undef,
					default => $notification_period,
				};
			}
		}
	}
}
