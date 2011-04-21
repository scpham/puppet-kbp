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
		"/etc/apache2/sites-available/puppetmaster":
			source  => "kbp_puppet/master/apache2/sites-available/puppetmaster",
			notify  => Exec["reload-apache2"],
			require => Kpackage["apache2"];
		# These are needed for the custom configuration
		"/usr/local/share/puppet":
			ensure  => directory;
		"/usr/local/share/puppet/rack":
			ensure  => directory;
	}

	mysql::server::db { "puppet":; }

	mysql::server::grant { "puppet":
		user     => "puppet",
		password => "ui6Nae9Xae4a";
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
				$factpath = '$vardir/lib/facter', $logdir = "/var/log/puppet", $pluginsync = true,
				$rackroot = "/usr/local/share/puppet/rack", $rundir = "/var/run/puppet",
				$ssldir = "/var/lib/puppet/ssl", $vardir = "/var/lib/puppet") {
	include gen_puppet::concat
	# This needs to be created within this define
	$rackdir = "${rackroot}/puppetmaster-${name}"

	# TODO Files that need to be customized
	# fileserver.conf
	# auth.conf

	# Create the rack directory tree.
	kfile { ["${rackdir}","${rackdir}/public","${rackdir}/tmp"]:
		ensure => directory,
	}

	# The apache config should determine where to listen on
	apache::site_config { "${name}":
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

	concat { $configfile:
		owner => "root",
		group => "root",
		mode  => 0640,
	}

	gen_puppet::concat::add_content { "Set header for main section in puppet.conf":
		target   => $configfile,
		content  => "[main]",
		order    => 10,
	}

	# Set the defaults for this resource
	kbp_puppet::master::set_main {
		"vardir":
			puppetmaster => $name,
			configfile   => $configfile,
			value        => $vardir;
		"ssldir":
			puppetmaster => $name,
			configfile   => $configfile,
			value        => $ssldir;
		"rundir":
			puppetmaster => $name,
			configfile   => $configfile,
			value        => $rundir;
		"logdir":
			puppetmaster => $name,
			configfile   => $configfile,
			value        => $logdir;
		"factpath":
			puppetmaster => $name,
			configfile   => $configfile,
			value        => $factpath;
		"pluginsync":
			puppetmaster => $name,
			configfile   => $configfile,
			value        => $pluginsync;
	}

	gen_puppet::concat::add_content { "Set header for agent section in puppet.conf":
		target   => $configfile,
		content  => "\n[agent]",
		order    => 20,
	}

	gen_puppet::concat::add_content { "Set header for master section in puppet.conf":
		target   => $configfile,
		content  => "\n[master]",
		order    => 30,
	}

	gen_puppet::concat::add_content { "Set header for queue section in puppet.conf":
		target   => $configfile,
		content  => "\n[queue]",
		order    => 40,
	}

	# TODO Set the other headers and the defaults that are part of the defined type

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

define kbp_puppet::master::set_main ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppet::master::config
	# resource you want to add this to.
	if ! defined(Kbp_puppet::Master::Config[$puppetmaster]) {
		fail("There's no kbp_puppet::master::config { \"${puppetmaster}\" }!")
	}

	if $var {
		$real_var = $var
	} else {
		$real_var = $name
	}

	gen_puppet::concat::add_content { "Set '$real_var' to '$value' for puppetmaster ${puppetmaster} in file ${configfile} in section 'main'":
		target   => "${configfile}",
		content  => "${real_var} = ${value}",
		order    => 15,
	}
}

define kbp_puppet::master::set_agent ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppet::master::config
	# resource you want to add this to.
	if ! defined(Kbp_puppet::Master::Config[$puppetmaster]) {
		fail("There's no kbp_puppet::master::config { \"${puppetmaster}\" }!")
	}

	if $var {
		$real_var = $var
	} else {
		$real_var = $name
	}

	gen_puppet::concat::add_content { "Set '$real_var' to '$value' for puppetmaster ${puppetmaster} in file ${configfile} in section 'agent'":
		target   => "${configfile}",
		content  => "${real_var} = ${value}",
		order    => 25,
	}
}

define kbp_puppet::master::set_master ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppet::master::config
	# resource you want to add this to.
	if ! defined(Kbp_puppet::Master::Config[$puppetmaster]) {
		fail("There's no kbp_puppet::master::config { \"${puppetmaster}\" }!")
	}

	if $var {
		$real_var = $var
	} else {
		$real_var = $name
	}

	gen_puppet::concat::add_content { "Set '$real_var' to '$value' for puppetmaster ${puppetmaster} in file ${configfile} in section 'master'":
		target   => "${configfile}",
		content  => "${real_var} = ${value}",
		order    => 35,
	}
}

define kbp_puppet::master::set_queue ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppet::master::config
	# resource you want to add this to.
	if ! defined(Kbp_puppet::Master::Config[$puppetmaster]) {
		fail("There's no kbp_puppet::master::config { \"${puppetmaster}\" }!")
	}

	if $var {
		$real_var = $var
	} else {
		$real_var = $name
	}

	gen_puppet::concat::add_content { "Set '$real_var' to '$value' for puppetmaster ${puppetmaster} in file ${configfile} in section 'queue'":
		target   => "${configfile}",
		content  => "${real_var} = ${value}",
		order    => 45,
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
