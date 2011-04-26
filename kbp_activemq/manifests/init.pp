class kbp_activemq {
	include gen_activemq

	kfile { "/etc/activemq/activemq.xml":
		source  => "kbp_activemq/activemq.xml",
		notify  => Exec["reload-activemq"],
		require => Package["activemq"];
	}
}
