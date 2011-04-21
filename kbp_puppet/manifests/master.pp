class kbp_puppet::master {
	include gen_puppet::master
	include gen_puppet::queue
	include kbp_puppet::vim
	include gen_rails
	include kbp_rabbitmq
	include kbp-apache::passenger
	include kbp_mysql::server
	class { "kbp_trending::puppetmaster":
		method => "munin";
	}

	gen_apt::preference { ["puppetmaster","puppetmaster-common"]:; }

	kfile {
		"/etc/puppet/fileserver.conf":
			source  => "kbp_puppet/master/fileserver.conf",
			require => Kpackage["puppetmaster"];
		# These are needed for the custom configuration
		"/usr/local/share/puppet":
			ensure  => directory;
		"/usr/local/share/puppet/rack":
			ensure  => directory;
	}

	# Enforce Puppet modules directory permissions.
	kfile {
		"/srv/puppet":
			ensure  => directory,
			owner   => "puppet",
			mode    => 2770,
			require => Kpackage["puppetmaster"];
	}

	# Enforce ownership and permissions
	setfacl {
		"Directory permissions in /srv/puppet for group root":
			dir     => "/srv/puppet",
			acl     => "default:group:root:rwx",
			require => Kfile["/srv/puppet"];
		"Directory permissions in /srv/puppet for user puppet":
			dir     => "/srv/puppet",
			acl     => "default:user:puppet:r-x",
			require => Kfile["/srv/puppet"];
	}

	apache::site { "puppetmaster":; }
}

# kbp_puppet::master::config
#
# Setup a puppetmaster in the Kumina way, using Apache and passenger.
# Allows for multiple puppetmasters with (mostly) different configs.
# Keep in mind that if you want default puppetmaster (which is
# probably most of the time), you just need to name it "default" and
# most settings will be indeed default.
#
define kbp_puppet::master::config ($address = "*:8140", $configfile = "/etc/puppet/puppet.conf", $debug = false,
				$dbname = false, $dbuser = false, $dbpasswd = false, $dbhost = false, $dbsocket = false,
				$factpath = '$vardir/lib/facter', $logdir = "/var/log/puppet", $pluginsync = true,
				$rackroot = "/usr/local/share/puppet/rack", $rundir = "/var/run/puppet",
				$ssldir = "/var/lib/puppet/ssl", $vardir = "/var/lib/puppet") {
	include gen_puppet::concat

	# If the name is 'default', we want to change the puppetmaster name (pname)
	# we're using for this instance to something without crud.
	if $name == 'default' {
		$pname = 'puppetmaster'
	} else {
		$sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')
		$pname - "puppetmaster-${sanitized_name}"
	}

	gen_puppet::master::config { $name:
		configfile => $configfile,
		debug      => $debug,
		factpath   => $factpath,
		logdir     => $logdir,
		pluginsync => $pluginsync,
		rackroot   => $rackroot,
		rundir     => $rundir,
		ssldir     => $ssldir,
		vardir     => $vardir,
	}

	# TODO Files that need to be customized
	# fileserver.conf
	# auth.conf

	# The apache config should determine where to listen on
	apache::site_config { "${pname}":
		address      => $address,
		documentroot => "${rackdir}/public",
	}

	# The vhost-addition should set the documentroot, the puppet directory,
	# the additional apache permissions and debugging options.
	kfile {
		"/etc/apache2/vhost-additions/${name}/permissions.conf":
			notify  => Exec["reload-apache2"],
			source  => "kbp_puppet/master/apache2/vhost-additions/permissions.conf";
		"/etc/apache2/vhost-additions/${name}/rack.conf":
			notify  => Exec["reload-apache2"],
			source  => "kbp_puppet/master/apache2/vhost-additions/rack.conf";
		"/etc/apache2/vhost-additions/${name}/ssl.conf":
			notify  => Exec["reload-apache2"],
			content => template("kbp_puppet/master/apache2/vhost-additions/ssl.conf.erb");
	}

	if $name == 'default' {
		$real_dbname = 'puppet'
		$real_dbuser = 'puppet'
		# Yes, we have a default password. That's not problem since MySQL
		# only allows access from restricted hosts.
		$real_dbpasswd = 'puppet'
	} else {
		$real_dbname = $dbname ? {
			false   => $pname,
			default => $dbname,
		}
		$real_dbuser = $dbuser ? {
			# TODO We should make sure this is never longer than 16 chars
			false   => "pm_${sanitized_name}",
			default => $dbuser,
		}
		$real_dbpasswd = $dbpasswd ? {
			false   => $pname,
			default => $dbpasswd,
		}
	}

	# Setup the MySQL only if one of the following condition apply:
	# - dbhost is false or localhost (false implies localhost)
	# - dbhost is equal to local fqdn
	if $dbhost or $dbhost == 'localhost' or $dbhost == $fqdn {
		mysql::server::db { $real_dbname:; }

		mysql::server::grant { $real_dbname:
			user     => $real_dbuser,
			password => $real_dbpasswd,
		}
	}

	gen_puppet::set_config {
		"Set database adapter for $name.":
			configfile => $configfile,
			var        => 'dbadapter',
			value      => 'mysql',
			section    => 'master';
		"Set database user for $name.":
			configfile => $configfile,
			var        => 'dbuser',
			value      => $real_dbuser,
			section    => 'master';
		"Set database name for $name.":
			configfile => $configfile,
			var        => 'dbname',
			value      => $real_dbname,
			section    => 'master';
		"Set database password for $name.":
			configfile => $configfile,
			var        => 'dbpassword',
			value      => $real_dbpasswd,
			section    => 'master';
	}

	# Only set the host if it's needed.
	if $dbhost {
		gen_puppet::set_config { "Set database host for $name.":
			configfile => $configfile,
			var        => 'dbhost',
			value      => $dbhost,
			section    => 'master',
		}
	}

	# Only set the socket if it's needed.
	if $dbsocket {
		gen_puppet::set_config { "Set database socket for $name.":
			configfile => $configfile,
			var        => 'dbsocket',
			value      => $dbsocket,
			section    => 'master',
		}
	}

	concat { "${rackdir}/config.ru":
		owner => "puppet",
		group => "puppet",
		mode  => 0640,
	}

	gen_puppet::concat::add_content { "Add header for config.ru":
		target   => "${rackdir}/config.ru",
		content  => '$0 = "master"',
		order    => 10,
	}

	gen_puppet::concat::add_content { "Add footer for config.ru":
		target   => "${rackdir}/config.ru",
		content  => "ARGV << \"--rack\"\nrequire 'puppet/application/master'\nrun Puppet::Application[:master].run\n",
		order    => 20,
	}

	if $debug {
		gen_puppet::concat::add_content { "Enable debug mode in config.ru":
			target  => "${rackdir}/config.ru",
			content => "ARGV << \"--debug\"\n",
		}
	}
}

define kbp_puppet::master::environment ($manifest, $manifestdir, $modulepath, $puppetmaster, $configfile = "/etc/puppet/puppet.conf") {
	# $puppetmaster should be the same as the $name from the kbp_puppet::master::config
	# resource you want to add this to.
	if ! defined(Kbp_puppet::Master::Config[$puppetmaster]) {
		fail("There's no kbp_puppet::master::config { \"${puppetmaster}\" }!")
	}

	gen_puppet::concat::add_content { "Add environment ${name} to puppetmaster ${puppetmaster} in file ${configfile}":
		target   => "${configfile}",
		content  => "\n[${name}]\nmanifestdir = ${manifestdir}\nmodulepath = ${modulepath}\nmanifest = ${manifest}\n\n",
		order    => 60,
	}
}
