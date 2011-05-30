class kbp_nagios::server::plugins inherits nagios::server::plugins {
}

class kbp_nagios::server inherits nagios::server {
	include kbp_nagios::server::plugins
	class { "kbp_nsca::server":
		package => "nagios";
	}

	kfile {
		"/etc/nagios3/conf.d/contacts.cfg":
			source => "kbp_nagios/nagios3/conf.d/contacts.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/generic-host.cfg":
			source => "kbp_nagios/nagios3/conf.d/generic-host.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/generic-service.cfg":
			source => "kbp_nagios/nagios3/conf.d/generic-service.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/hostgroups.cfg":
			source => "kbp_nagios/nagios3/conf.d/hostgroups.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/misc_commands.cfg":
			source => "kbp_nagios/nagios3/conf.d/misc_commands.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/notify_commands.cfg":
			source => "kbp_nagios/nagios3/conf.d/notify_commands.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/passive_services.cfg":
			source => "kbp_nagios/nagios3/conf.d/passive_services.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/servicegroups.cfg":
			source => "kbp_nagios/nagios3/conf.d/servicegroups.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/services.cfg":
			source => "kbp_nagios/nagios3/conf.d/services.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/nagios3/conf.d/timeperiods.cfg":
			source => "kbp_nagios/nagios3/conf.d/timeperiods.cfg",
			notify => Exec["reload-nagios3"];
		"/etc/cron.d/nagios-check-alive-cron":
			source => "kbp_nagios/nagios-check-alive-cron";
		"/usr/bin/nagios-check-alive":
			source => "kbp_nagios/nagios-check-alive",
			mode   => 755;
	}
}
