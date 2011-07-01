# Author: Kumina bv <support@kumina.nl>

# This class is for system timekeeping with ntpd (or openntpd on lenny)
# Class: kbp_time
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_time {
	if ((versioncmp($lsbdistrelease,"5.0") >= 0) and (versioncmp($lsbdistrelease,"6.0")) < 0 ) { #this is lenny
		include openntpd::common
	}
	if (versioncmp($lsbdistrelease, "6.0") >= 0) { # This is squeeze or ewer
		include ntp
	}
}
