# Author: Kumina bv <support@kumina.nl>

# Class: kbp_apache
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_apache_new {
	include gen_apache
	include kbp_munin::client::apache

	gen_ferm::rule { "HTTP connections":
		proto  => "tcp",
		dport  => "80",
		action => "ACCEPT";
	}

	kfile {
		"/etc/apache2/mods-available/deflate.conf":
			source  => "kbp_apache/mods-available/deflate.conf",
			require => Package["apache2"],
			notify  => Exec["reload-apache2"];
		"/etc/apache2/conf.d/security":
			source  => "kbp_apache/conf.d/security",
			require => Package["apache2"],
			notify  => Exec["reload-apache2"];
		"/srv/www":
			ensure => directory;
	}

	gen_logrotate::rotate { "apache2":
		logs       => "/var/log/apache2/*.log",
		options    => ["weekly", "rotate 52", "missingok", "notifempty", "create 640 root adm", "compress", "delaycompress", "sharedscripts", "dateext"],
		postrotate => "/etc/init.d/apache2 reload > /dev/null",
		require    => Package["apache2"];
	}

	kbp_apache_new::module { ["deflate","rewrite"]:; }

	@kpackage { "php5-gd":
		ensure  => latest,
		require => Package["apache2"],
		notify  => Exec["reload-apache2"];
	}

	kbp_monitoring::http { "http_${fqdn}":; }
}

# Class: kbp_apache::passenger
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_apache_new::passenger {
	include kbp_apache_new
	include kbp_apache_new::ssl

	kpackage { "libapache2-mod-passenger":
		ensure => latest;
	}

	kbp_apache_new::module { "passenger":
		require => Kpackage["libapache2-mod-passenger"];
	}
}

class kbp_apache_new::php {
	include kbp_apache_new
	include gen_base::libapache2-mod-php5
}

# Class: kbp_apache::ssl
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_apache_new::ssl {
	kfile { "/etc/apache2/ssl":
		ensure  => directory,
		require => Package["apache2"];
	}

	gen_ferm::rule { "HTTPS connections":
		proto  => "tcp",
		dport  => "443",
		action => "ACCEPT";
	}

	kbp_apache_new::module { "ssl":; }
}

# Define: kbp_apache::site
#
# Parameters:
#	priority
#		Undocumented
#	ensure
#		Undocumented
#	max_check_attempts
#		For overriding the default max_check_attempts of the service
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_apache_new::site($ensure="present", $serveralias=false, $documentroot="/srv/www/${name}", $address=false, $address6=false, $port=false,
		$make_default=false, $ssl=false, $key=false, $cert=false, $intermediate=false, $redirect_non_ssl=true,
		$auth=false, $max_check_attempts=false, $monitor_path=false, $monitor_response=false, $monitor_probe=false, $monitor=true,
		$smokeping=true) {
	include kbp_apache_new
	if $ssl {
		include kbp_apache_new::ssl
	}

	$real_name   = regsubst($name,'^(.*)_(.*)$','\1')
	$dontmonitor = ["default","default-ssl","localhost"]

	if $ensure == "present" and $monitor and ! ($name in $dontmonitor) {
		kbp_monitoring::site { $name:
			max_check_attempts => $max_check_attempts,
			auth               => $auth,
			path               => $monitor_path,
			response           => $monitor_response;
		}

		if $smokeping {
			kbp_smokeping::target { $name:
				probe => $monitor_probe ? {
					false   => $auth ? {
						false => undef,
						true  => "FPing",
					},
					default => $monitor_probe,
				},
				path  => $monitor_path;
			}
		}
	}

	gen_apache::site { $name:
		ensure           => $ensure,
		serveralias      => $serveralias,
		documentroot     => $documentroot,
		address          => $address,
		address6         => $address6,
		port             => $port,
		make_default     => $make_default,
		ssl              => $ssl,
		key              => $key,
		cert             => $cert,
		intermediate     => $intermediate,
		redirect_non_ssl => $redirect_non_ssl;
	}

	if $ssl or $key or $cert or $intermediate {
		kbp_monitoring::sslcert { $real_name:
			path => "/etc/ssl/certs/${real_name}.pem";
		}
	}
}

define kbp_apache_new::module {
	gen_apache::module { $name:; }
}

define kbp_apache_new::forward_vhost ($forward, $ensure="present", $serveralias=false) {
	gen_apache::forward_vhost { $name:
		forward      => $forward,
		ensure       => $ensure,
		serveralias  => $serveralias,
		documentroot => "/srv/www/";
	}
}

define kbp_apache_new::vhost_addition($ensure="present", $content=false, $source=false) {
	gen_apache::vhost_addition { $name:
		ensure  => $ensure,
		content => $content,
		source  => $source;
	}
}
