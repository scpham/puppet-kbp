# Author: Kumina bv <support@kumina.nl>

# Class: kbp_syslog::server
#
# Parameters:
#	environmentonly
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server($environmentonly=false) {
	include "kbp_syslog::server::$lsbdistcodename"

	if ($environmentonly) {
		Gen_ferm::Rule <<| tag == "syslog_${environment}" |>>
	} else {
		Gen_ferm::Rule <<| tag == "syslog" |>>
	}
}

# Class: kbp_syslog::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client {
	include "kbp_syslog::client::$lsbdistcodename"

	@@gen_ferm::rule { "Syslog traffic from ${fqdn}":
		saddr  => $fqdn,
		proto  => "udp",
		dport  => 514,
		action => "ACCEPT",
		tag    => ["syslog","syslog_${environment}"];
	}
}

# Class: kbp_syslog::server::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::etch inherits syslog-ng::server {
	kfile { "/etc/logrotate.d/syslog-ng":
		source => "kbp_syslog/server/logrotate.d/syslog-ng";
	}
}

# Class: kbp_syslog::client::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client::etch inherits sysklogd::client {
}

# Class: kbp_syslog::server::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::lenny inherits rsyslog::server {
	include kbp_logrotate
	gen_logrotate::rotate { "rsyslog":
		log => ["/var/log/syslog", "/var/log/mail.info", "/var/log/mail.warn",
			"/var/log/mail.err", "/var/log/mail.log", "/var/log/daemon.log",
			"/var/log/kern.log", "/var/log/auth.log", "/var/log/user.log",
			"/var/log/lpr.log", "/var/log/cron.log", "/var/log/debug",
			"/var/log/messages"],
		options => ["daily", "rotate 90", "missingok", "notifempty", "compress", "delaycompress", "sharedscripts"],
		postrotate => "invoke-rc.d rsyslog reload > /dev/null";
	}
}

# Class: kbp_syslog::client::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client::lenny inherits rsyslog::client {
}

# Class: kbp_syslog::server::squeeze
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::squeeze inherits rsyslog::server {
	include kbp_logrotate
	gen_logrotate::rotate { "rsyslog":
		log => ["/var/log/syslog", "/var/log/mail.info", "/var/log/mail.warn",
			"/var/log/mail.err", "/var/log/mail.log", "/var/log/daemon.log",
			"/var/log/kern.log", "/var/log/auth.log", "/var/log/user.log",
			"/var/log/lpr.log", "/var/log/cron.log", "/var/log/debug",
			"/var/log/messages"],
		options => ["daily", "rotate 90", "missingok", "notifempty", "compress", "delaycompress", "sharedscripts"],
		postrotate => "invoke-rc.d rsyslog reload > /dev/null";
	}
}

# Class: kbp_syslog::client::squeeze
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client::squeeze inherits rsyslog::client {
}

# Additional options
# Class: kbp_syslog::server::mysql
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::mysql {
	include kbp_syslog::server
	include "kbp_syslog::mysql::$lsbdistcodename"
}

# Class: kbp_syslog::mysql::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::mysql::etch {
	err ("This is not implemented for Etch or earlier!")
}

# Class: kbp_syslog::mysql::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::mysql::lenny inherits rsyslog::mysql {
}
