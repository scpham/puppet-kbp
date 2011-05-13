class kbp_nfs::server ($default_config = true) {
	include gen_nfs::server
	include kbp_trending::nfsd

	if $default_config {
		# Use this for a default NFS server
		kbp_nfs::server::config { "dummy for nfs server":
			incoming_port => "4000",
			outgoing_port => "4001",
			mountd_port   => "4002",
			lock_port     => "4003",
			rpcmountdopts => "--state-directory-path /srv/nfs",
			statdopts     => "--state-directory-path /srv/nfs",
		}
	}
}

define kbp_nfs::server::config ($need_gssd = "no", $need_idmapd = "no", $need_statd = "yes",
				$need_svcgssd = "no", $mountd_port = false, $incoming_port = false,
				$outgoing_port = false, $lock_port = false, $rpcnfsdcount = "8",
				$rpcnfsdpriority = "0", $rpcmountdopts = "", $rpcsvcgssdopts = "",
				$statdopts = "") {
	gen_nfs::server::config { $name:
		need_gssd       => $need_gssd,
		need_idmapd     => $need_idmapd,
		need_statd      => $need_statd,
		need_svcgssd    => $need_svcgssd,
		mountd_port     => $mountd_port,
		incoming_port   => $incoming_port,
		outgoing_port   => $outgoing_port,
		lock_port       => $lock_port,
		rpcnfsdcount    => $rpcnfsdcount,
		rpcnfsdpriority => $rpcnfsdpriority,
		rpcmountdopts   => $rpcmountdopts,
		rpcsvcgssdopts  => $rpcsvcgssdopts,
		statdopts       => $statdopts,
	}

	Ferm::Rule <<| tag == "ferm_nfs_rule_${environment}" |>> {
		dport => "(2049 ${incoming_port} ${outgoing_port} ${mountd_port} ${lock_port})",
	}
}
