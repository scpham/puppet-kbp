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
		$need_svcgssd = "no", $mountd_port = 4002, $incoming_port = 4000,
		$outgoing_port = 4001, $lock_port = 4003, $rpcnfsdcount = "8",
		$rpcnfsdpriority = "0", $rpcmountdopts = "", $rpcsvcgssdopts = "",
		$statdopts = "") {
	include kbp_trending::nfsd
	include kbp_monitoring::nfs::server
	class { "gen_nfs::server":
		incoming_port => $incoming_port,
		outgoing_port => $outgoing_port,
		mountd_port   => $mountd_port,
		lock_port     => $lock_port,
		rpcmountdopts => "--state-directory-path /srv/nfs",
		statdopts     => "--state-directory-path /srv/nfs";
	}

	Gen_ferm::Rule <<| tag == "nfs_${environment}" |>> {
		dport => "(111 2049 ${incoming_port} ${outgoing_port} ${mountd_port} ${lock_port})",
	}
	Gen_ferm::Rule <<| tag == "nfs_monitoring" |>>
}
