# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ocfs2
#
# Parameters:
#  otherhost
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_ocfs2($ocfs2_tag=false, $use_ipaddress=$external_ipaddress) {
  include gen_ocfs2
  include gen_base::libcups2

  $real_tag = $ocfs2_tag ? {
    false   => "ocfs2_${environment}_${custenv}",
    default => "ocfs2_${environment}_${custenv}_${ocfs2_tag}",
  }

  concat { '/etc/ocfs2/cluster.conf':
    notify => Kservice['o2cb'];
  }

  concat::add_content { 'ocfs2':
    content => template('kbp_ocfs2/basic'),
    target  => '/etc/ocfs2/cluster.conf';
  }

  @@concat::add_content { "ocfs2_${fqdn}":
    content => template('kbp_ocfs2/node'),
    target  => '/etc/ocfs2/cluster.conf',
    tag     => $real_tag;
  }

  Concat::Add_content <<| tag == $real_tag |>>

  kbp_ferm::rule { 'OCFS2 connections':
    saddr    => $use_ipaddress,
    proto    => 'tcp',
    dport    => 7777,
    action   => 'ACCEPT',
    exported => true,
    ferm_tag => $real_tag;
  }

  Kbp_ferm::Rule <<| tag == $real_tag |>>
}
