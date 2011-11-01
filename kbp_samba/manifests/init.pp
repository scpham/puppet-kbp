# Author: Kumina bv <support@kumina.nl>

# Class: kbp_samba::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_samba::server inherits samba::server {
  gen_ferm::rule { "Samba traffic (netbios-ns)":
    proto     => "udp",
    dport     => "137",
    action    => "ACCEPT";
  }

  gen_ferm::rule { "Samba traffic (netbios-dgm)":
    proto     => "udp",
    dport     => "138",
    action    => "ACCEPT";
  }

  gen_ferm::rule { "Samba traffic (netbios-ssn)":
    proto     => "tcp",
    dport     => "139",
    action    => "ACCEPT";
  }

  gen_ferm::rule { "Samba traffic (microsoft-ds)":
    proto     => "tcp",
    dport     => "445",
    action    => "ACCEPT";
  }
}
