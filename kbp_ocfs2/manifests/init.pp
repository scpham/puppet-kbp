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
class kbp_ocfs2($ocfs2_tag="") {
  include gen_ocfs2

  $real_tag = "ferm_ocfs2_${environment}_${ocfs2_tag}"

  concat { "/etc/ocfs2/cluster.conf":
    notify => Service["o2cb"];
  }

  concat::add_content { "Ocfs2 cluster basic config":
    content => template("kbp_ocfs2/basic"),
    target  => "/etc/ocfs2/cluster.conf";
  }

  Concat::Add_content <<| tag == $real_tag |>>

  @@concat::add_content { "Ocfs2 cluster config for ${fqdn}":
    content => template("kbp_ocfs2/node"),
    target  => "/etc/ocfs2/cluster.conf",
    tag     => $real_tag;
  }

  Gen_ferm::Rule <<| tag == $real_tag |>>

  @@gen_ferm::rule { "OCFS2 connections from ${fqdn}":
    saddr  => $fqdn,
    proto  => "tcp",
    dport  => 7777,
    action => "ACCEPT",
    tag    => $real_tag;
  }
}
