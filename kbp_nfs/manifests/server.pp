# Author: Kumina bv <support@kumina.nl>

# Class: kbp_nfs::server
#
# Parameters:
#	default_config
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_nfs::server($need_gssd = "no", $need_idmapd = "no", $need_statd = "yes",
		$need_svcgssd = "no", $mountd_port = false, $incoming_port = false,
		$outgoing_port = false, $lock_port = false, $rpcnfsdcount = "8",
		$rpcnfsdpriority = "0", $rpcmountdopts = "", $rpcsvcgssdopts = "",
		$statdopts = "") {
	include kbp_trending::nfsd
	include kbp_monitoring::nfs
	class { "gen_nfs::server":
		incoming_port => "4000",
		outgoing_port => "4001",
		mountd_port   => "4002",
		lock_port     => "4003",
		rpcmountdopts => "--state-directory-path /srv/nfs",
		statdopts     => "--state-directory-path /srv/nfs";
	}

	Gen_ferm::Rule <<| tag == "nfs_${environment}" |>> {
		dport => "(111 2049 ${incoming_port} ${outgoing_port} ${mountd_port} ${lock_port})",
	}
	Gen_ferm::Rule <<| tag == "nfs_monitoring" |>>
}
