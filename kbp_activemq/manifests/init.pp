class kbp_activemq {
	include gen_activemq
	include kbp_ferm

	kfile {
		"/etc/activemq/activemq.xml":
			source  => "kbp_activemq/activemq.xml",
			notify  => Exec["reload-activemq"],
			require => Package["activemq"];
		"/etc/activemq/jetty.xml":
			source  => "kbp_activemq/jetty.xml",
			notify  => Exec["reload-activemq"],
			require => Package["activemq"];
	}

	# Open the management port
	ferm::rule { "Connections to admin port":
		dport  => "8161",
		proto  => "tcp",
		saddr  => "localhost",
		action => "ACCEPT",
	}
}
