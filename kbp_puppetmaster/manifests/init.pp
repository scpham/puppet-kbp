class kbp_puppetmaster {
	include kbp-apache::passenger
	include kbp_mysql::server
	include kbp_vim::addon-manager
	class { "kbp_trending::puppetmaster":
		method => "munin";
	}

	gen_apt::preference { ["puppetmaster","puppetmaster-common"]:; }

	gen_apt::source { "rabbitmq":
		uri          => "http://www.rabbitmq.com/debian",
		distribution => "testing",
		components   => ["main"];
	}

	kpackage {
		"puppetmaster":
			ensure  => present,
			require => Kfile["/etc/default/puppetmaster","/etc/apt/preferences.d/puppetmaster"];
		["rails","rabbitmq-server","vim-puppet","libmysql-ruby","puppetmaster-common"]:
			ensure  => latest;
	}

	service { "puppetqd":
		hasstatus => true,
		ensure    => running,
		require   => Kpackage["puppetmaster"];
	}

	exec {
		"Install syntax highlighting for .pp files":
			command => "/usr/bin/vim-addons -w install puppet;",
			creates => "/var/lib/vim/addons/syntax/puppet.vim",
			require => Kpackage["vim-puppet","vim-addon-manager"];
		"Install the Stomp gem":
			command => "/usr/bin/gem install stomp",
			creates => "/var/lib/gems/1.8/gems/stomp-1.1.8",
			require => Kpackage["rails"];
		"reload-rabbitmq":
			command     => "/etc/init.d/rabbitmq-server reload",
			refreshonly => true;
	}

	kfile {
		"/etc/puppet/puppet.conf":
			source  => "kbp_puppetmaster/puppet.conf",
			require => Kpackage["puppetmaster"];
		"/etc/puppet/fileserver.conf":
			source  => "kbp_puppetmaster/fileserver.conf",
			require => Kpackage["puppetmaster"];
		"/etc/default/puppetmaster":
			source => "kbp_puppetmaster/default/puppetmaster";
		"/etc/default/puppetqd":
			source => "kbp_puppetmaster/default/puppetqd";
		"/etc/rabbitmq/rabbitmq-env.conf":
			source  => "kbp_puppetmaster/rabbitmq/rabbitmq-env.conf",
			require => Kpackage["rabbitmq-server"];
		"/etc/apache2/sites-available/puppetmaster":
			source  => "kbp_puppetmaster/apache2/sites-available/puppetmaster",
			notify  => Exec["reload-apache2"],
			require => Kpackage["apache2"];
		# These are needed for the custom configuration
		"/usr/local/share/puppet":
			ensure  => directory;
		"/usr/local/share/puppet/rack":
			ensure  => directory;
		# TODO Delete until end, once custom config is working
		"/usr/share/puppet":
			ensure  => directory;
		"/usr/share/puppet/rack":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd/public":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd/tmp":
			ensure  => directory;
		"/usr/share/puppet/rack/puppetmasterd/config.ru":
			source  => "kbp_puppetmaster/config.ru",
			owner   => "puppet",
			group   => "puppet";
		# TODO End of deletion
		"/var/lib/puppet/ssl/ca":
			ensure  => directory,
			owner   => "puppet",
			group   => "puppet",
			mode    => 770,
			require => Kpackage["puppetmaster"];
		"/var/lib/puppet/ssl/ca/ca_crl.pem":
			source => "kbp_puppetmaster/ssl/ca/ca_crl.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 664,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/ca_crt.pem":
			source => "kbp_puppetmaster/ssl/ca/ca_crt.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 660,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/ca_key.pem":
			source => "kbp_puppetmaster/ssl/ca/ca_key.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 660,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/ca_pub.pem":
			source => "kbp_puppetmaster/ssl/ca/ca_pub.pem",
			owner  => "puppet",
			group  => "puppet",
			mode   => 640,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/ca/signed":
			ensure => directory,
			owner  => "puppet",
			group  => "puppet",
			mode   => 770;
		"/usr/lib/rabbitmq/lib/rabbitmq_server-2.4.1/plugins/amqp_client-2.4.1.ez":
			source  => "kbp_puppetmaster/rabbitmq/plugins/amqp_client-2.4.1.ez",
			require => Kpackage["rabbitmq-server"],
			notify  => Exec["reload-rabbitmq"];
		"/usr/lib/rabbitmq/lib/rabbitmq_server-2.4.1/plugins/rabbit_stomp-2.4.1.ez":
			source  => "kbp_puppetmaster/rabbitmq/plugins/rabbit_stomp-2.4.1.ez",
			require => Kpackage["rabbitmq-server"],
			notify  => Exec["reload-rabbitmq"];
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

	# This is so puppetmaster doesn't congest MySQL connections
	# TODO Check if this is still necessary, ticket #597
	kfile { "/etc/mysql/conf.d/waittimeout.cnf":
		content => "[mysqld]\nwait_timeout = 3600\n",
		notify  => Service["mysql"];
	}

	apache::site { "puppetmaster":; }
}

define kbp_puppetmaster::config ($address = "*:8140", $configfile = "/etc/puppet/puppet.conf", $debug = false,
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
			source  => "kbp_puppetmaster/apache2/vhost-additions/permissions.conf";
		"/etc/apache2/vhost-additions/${name}/rack.conf":
			notify  => Exec["reload-apache2"],
			source  => "kbp_puppetmaster/apache2/vhost-additions/rack.conf";
		"/etc/apache2/vhost-additions/${name}/ssl.conf":
			notify  => Exec["reload-apache2"],
			content => template("kbp_puppetmaster/apache2/vhost-additions/ssl.conf.erb");
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
	kbp_puppetmaster::set_main {
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

define kbp_puppetmaster::set_main ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppetmaster::config
	# resource you want to add this to.
	if ! defined(Kbp_puppetmaster::Config[$puppetmaster]) {
		fail("There's no kbp_puppetmaster::config { \"${puppetmaster}\" }!")
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

define kbp_puppetmaster::set_agent ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppetmaster::config
	# resource you want to add this to.
	if ! defined(Kbp_puppetmaster::Config[$puppetmaster]) {
		fail("There's no kbp_puppetmaster::config { \"${puppetmaster}\" }!")
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

define kbp_puppetmaster::set_master ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppetmaster::config
	# resource you want to add this to.
	if ! defined(Kbp_puppetmaster::Config[$puppetmaster]) {
		fail("There's no kbp_puppetmaster::config { \"${puppetmaster}\" }!")
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

define kbp_puppetmaster::set_queue ($puppetmaster, $value, $configfile = "/etc/puppet/puppet.conf", $var = false) {
	# $puppetmaster should be the same as the $name from the kbp_puppetmaster::config
	# resource you want to add this to.
	if ! defined(Kbp_puppetmaster::Config[$puppetmaster]) {
		fail("There's no kbp_puppetmaster::config { \"${puppetmaster}\" }!")
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

define kbp_puppetmaster::environment ($manifest, $manifestdir, $modulepath, $puppetmaster, $configfile = "/etc/puppet/puppet.conf") {
	# $puppetmaster should be the same as the $name from the kbp_puppetmaster::config
	# resource you want to add this to.
	if ! defined(Kbp_puppetmaster::Config[$puppetmaster]) {
		fail("There's no kbp_puppetmaster::config { \"${puppetmaster}\" }!")
	}

	gen_puppet::concat::add_content { "Add environment ${name} to puppetmaster ${puppetmaster} in file ${configfile}":
		target   => "${configfile}",
		content  => "\n[${name}]\nmanifestdir = ${manifestdir}\nmodulepath = ${modulepath}\nmanifest = ${manifest}\n\n",
		order    => 60,
	}
}
