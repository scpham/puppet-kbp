# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ocfs2
#
# Parameters:
#	otherhost
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_ocfs2($otherhost) {
	gen_ferm::rule { "OCFS2 connections from ${otherhost}":
		saddr  => $otherhost,
		proto  => "tcp",
		dport  => 7777,
		action => "ACCEPT";
	}
}
