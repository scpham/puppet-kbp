class kbp_activemq {
	include gen_activemq

	kfile { "/etc/activemq/activemq.xml":
		source  => "kbp_activemq/activemq.xml",
		require => Package["activemq"];
	}
}
