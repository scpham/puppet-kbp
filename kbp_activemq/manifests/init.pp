class kbp_activemq {
	include gen_activemq

	kfile { "/etc/activemq/activemq.xml":
		source  => "kbp_activemq/activemq.xml",
		notify  => Service["activemq"],
		require => Package["activemq"];
	}
}
