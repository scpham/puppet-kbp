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
		# TODO remove this one once the PM works properly, ticket #598
		"/var/lib/puppet/ssl/ca/signed/icinga.kumina.nl.pem":
			source => "kbp_puppetmaster/ssl/ca/signed/icinga.kumina.nl.pem";
		"/var/lib/puppet/ssl/private_keys/puppet.pem":
			source => "kbp_puppetmaster/ssl/private_keys/puppet.pem",
			owner  => "puppet",
			mode   => 600,
			notify => Exec["reload-apache2"];
		"/var/lib/puppet/ssl/certs/puppet.pem":
			source => "kbp_puppetmaster/ssl/certs/puppet.pem",
			notify => Exec["reload-apache2"];
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

define kbp_puppetmaster::config () {
	# TODO Files that need to be customized
	# puppet.conf
	# fileserver.conf
	# auth.conf
	# config.ru
	# apache config
}
