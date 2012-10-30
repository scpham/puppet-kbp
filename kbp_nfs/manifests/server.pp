# Author: Kumina bv <support@kumina.nl>

# Class: kbp_nfs::server
#
# Parameters:
#  default_config
#    Undocumented
#
# Actions:
#  Undocumented
#
# Parameters:
#  failover_ip
#    False if this isn't a failover setup, otherwise should be the IP address that's
#    used in the failover.
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_nfs::server($need_gssd='no', $need_idmapd='no', $need_statd='yes', $need_svcgssd='no', $mountd_port=4002, $incoming_port=4000, $outgoing_port=4001, $lock_port=4003, $rpcnfsdcount='8', $rpcnfsdpriority='0',
    $rpcmountdopts='', $rpcsvcgssdopts='', $statdopts='', $nfs_tag='default', $failover_ip=false, $monitor_ip_proxy=false) {
  include kbp_trending::nfsd
  class {
    'kbp_icinga::nfs::server':
      failover_ip   => $failover_ip,
      ip_proxy      => $monitor_ip_proxy;
    'gen_nfs::server':
      failover_ip   => $failover_ip,
      incoming_port => $incoming_port,
      outgoing_port => $outgoing_port,
      mountd_port   => $mountd_port,
      lock_port     => $lock_port,
      rpcmountdopts => '--state-directory-path /srv/nfs',
      statdopts     => '--state-directory-path /srv/nfs';
  }

  $real_tag = "nfs_${environment}_${dcenv}_${nfs_tag}"

  # We always keep the state in /srv/nfs, to make setting up failover NFS easier
  # make sure the directory exists.
  file { "/srv/nfs":
    ensure => directory,
  }

  concat { "/etc/exports":
    force  => true,
    notify => Exec["export-nfsd"];
  }

  Kbp_ferm::Rule <<| tag == $real_tag |>> {
    dport => "(111 2049 ${incoming_port} ${outgoing_port} ${mountd_port} ${lock_port})",
  }

  Kbp_ferm::Rule <<| tag == "nfs_monitoring" |>>

  Kbp_nfs::Client::Export_opts <<| tag == $real_tag |>>
}
