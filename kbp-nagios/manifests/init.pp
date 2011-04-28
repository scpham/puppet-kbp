class kbp-nagios {
	kfile { "/etc/cron.d/nagios-check-alive":
		source => "kbp-nagios/nagios-check-alive";
	}
}
