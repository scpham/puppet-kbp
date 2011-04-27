class kbp-nagios::server::plugins inherits nagios::server::plugins {
}

class kbp-nagios::server inherits nagios::server {
	include kbp-nagios::server::plugins

	@@ferm::new::rule { "NRPE connections from ${fqdn}_v46":
		saddr  => "${fqdn}",
		proto  => "tcp",
		dport  => "5666",
		action => "ACCEPT",
		tag    => "ferm";
	}

	kfile { "/etc/nagios3/local.d":
		source => "kbp-nagios/nagios3/local.d",
		recurse => true,
		ignore => ".*.swp",
		notify => Exec["reload-nagios3"],
	}

	kfile {
		"/etc/nagios3/conf.d/contacts.cfg":
			source => "kbp-nagios/nagios3/conf.d/contacts.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/generic-host.cfg":
			source => "kbp-nagios/nagios3/conf.d/generic-host.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/generic-service.cfg":
			source => "kbp-nagios/nagios3/conf.d/generic-service.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/hostgroups.cfg":
			source => "kbp-nagios/nagios3/conf.d/hostgroups.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/misc_commands.cfg":
			source => "kbp-nagios/nagios3/conf.d/misc_commands.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/notify_commands.cfg":
			source => "kbp-nagios/nagios3/conf.d/notify_commands.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/passive_services.cfg":
			source => "kbp-nagios/nagios3/conf.d/passive_services.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/servicegroups.cfg":
			source => "kbp-nagios/nagios3/conf.d/servicegroups.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/services.cfg":
			source => "kbp-nagios/nagios3/conf.d/services.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/timeperiods.cfg":
			source => "kbp-nagios/nagios3/conf.d/timeperiods.cfg",
			notify => Exec["reload-nagios3"];
	}
}
