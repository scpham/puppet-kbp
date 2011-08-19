# Author: Kumina bv <support@kumina.nl>

# Class: kbp_mysql::server
#
# Parameters:
#	otherhost
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_mysql::server($otherhost=false) {
	include mysql::server
	include kbp_trending::mysql
	class { "kbp_mysql::monitoring::icinga::server":
		otherhost => $otherhost,
	}

	if $otherhost {
		@@gen_ferm::rule { "MySQL connections from ${fqdn}":
			tag    => "mysql_${environment}",
			dport  => '3306',
			proto  => 'tcp',
			saddr  => $fqdn,
			action => 'ACCEPT',
		}
	}

	Gen_ferm::Rule <<| tag == "mysql_${environment}" |>>
	Gen_ferm::Rule <<| tag == "mysql_monitoring" |>>
}

# Class: kbp_mysql::slave
#
# Parameters:
#	customtag
#		Undocumented
#	otherhost
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_mysql::slave($otherhost, $customtag="mysql_${environment}", $monitoring_ha=false) {
	class { "kbp_mysql::server":
		otherhost => $otherhost,
	}

	Gen_ferm::Rule <<| tag == "mysql_${fqdn}" |>>
	Mysql::Server::Grant <<| tag == "mysql_${fqdn}" |>>

	@@mysql::server::grant { "repl":
		user        => "repl",
		password    => "etohsh8xahNu",
		hostname    => $fqdn,
		db          => "*",
		permissions => "replication slave",
		tag         => $otherhost;
	}

	mysql::server::grant { "nagios_slavecheck":
		user        => "nagios",
		db          => "*",
		permissions => "super, replication client";
	}

	@@gen_ferm::rule { "MySQL slaving from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 3306,
		action => "ACCEPT",
		tag    => $otherhost;
	}

	kbp_icinga::service { "mysql_slaving":
		service_description => "MySQL slaving",
		check_command       => "check_mysql_slave",
		nrpe                => true,
		ha                  => true;
	}
}

# Class: kbp_mysql::monitoring::icinga::server
#
# Parameters:
#	otherhost
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_mysql::monitoring::icinga::server($otherhost=false) {
	kbp_icinga::service { "mysql":
		service_description => "MySQL service",
		check_command        => "check_mysql",
		nrpe                => true;
	}

	if $otherhost {
		gen_icinga::servicedependency { "mysql_dependency_${fqdn}":
			dependent_service_description => "MySQL service",
			host_name                     => $otherhost,
			service_description           => "MySQL service";
		}
	}

	mysql::user { "monitoring":
		user => "nagios";
	}
}

# Class: kbp_mysql::puppetmaster
#
# Actions:
#	Setup a database and user for the puppetmaster, as requested.
#
# Depends:
#	gen_puppet
#	kbp_mysql::server
#
class kbp_mysql::puppetmaster {
	Mysql::Server::Db <<| tag == "mysql_puppetmaster" |>>
	Mysql::Server::Grant <<| tag == "mysql_puppetmaster" |>>
}

# Define: kbp_mysql::client
#
# Parameters:
#	customtag
#		Use a different tag than the default "mysql_${environment}"
#
# Actions:
#	Open the firewall on the server to allow access from this client.
#	Make sure the title of the resource is something sane, since if you
#	use "dummy" everywhere, it still clashes.
#
# Depends:
#	gen_ferm
#	gen_puppet
#
define kbp_mysql::client ($customtag="mysql_${environment}") {
	@@gen_ferm::rule { "MySQL connections from ${fqdn} for ${name}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 3306,
		action => "ACCEPT",
		tag    => $customtag;
	}
}

