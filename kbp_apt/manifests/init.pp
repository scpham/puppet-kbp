# Author: Kumina bv <support@kumina.nl>

# Class: kbp_apt
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_apt {
	include gen_apt

	# Keys for backports, kumina, cassandra, ksplice, jenkins, rabbitmq (in this order)
	gen_apt::key { ["16BA136C","498B91E6","8D77295D","B6D4038E","D50582E6","056E8E56"]:; }

	gen_apt::cron_apt::config {
		# First, update the package list and don't mail us. A second run is done to see if there are packages to be installed
		# Because puppet could have updated them in the meantime.
		"update":
			mailon      => "", # Don't send mail
			mailto      => "reports",
			crontime    => "0 20 * * *", # 8 in the evening
			configfile  => "/etc/cron-apt/config";
		# Now mail if we need to upgrade packages by hand
		"mail for manual upgrade":
			mailon      => "upgrade",
			mailto      => "reports",
			crontime    => "0 4 * * *", # 4 in the morning
			apt_options => "-V",
			configfile  => "/etc/cron-apt/config-mail";
	}
}
