# Author: Kumina bv <support@kumina.nl>

# Class: kbp_powerdns::master
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_powerdns::master {
  include powerdns::master

  Kbp_ferm::Rule <<| tag == "bind_${environment}" |>>

  # Poweradmin MySQL access
  Kbp_ferm::Rule <<| tag == "poweradmin_${environment}" |>>

  Gen_ferm::Rule <<| tag == "dns_monitoring" |>>
}

class kbp_powerdns::authoritative::master {
  include gen_powerdns
  include gen_powerdns::backend::mysql
  include kbp_mysql::server

#  include kbp_mysql::server::ssl
}

class kbp_powerdns::authoritative::hidden::master ($db_password="pdns") {
  include kbp_mysql::master
  include kbp_mysql::server::ssl
  #include poweradmin

  file { "/etc/mysql/conf.d/master.cnf":
    content => inline_template("[mysqld]\nserver-id=1\nlog-bin=mysql-bin");
  }

#  mysql::db { "pdns":; }
#  mysql::grant { "Allow pdns user access to pdns database":
#    user     => "pdns",
#    password => $db_password;
#  }
}


class kbp_powerdns::authoritative::hidden::slave ($db_password="pdns"){
  include gen_powerdns
  class { "gen_powerdns::backend::mysql":
    db_password => $db_password;
  }

  include kbp_mysql::server::ssl
  include kbp_mysql::slave

  file { "/etc/mysql/conf.d/slave.cnf":
    content => inline_template("[mysqld]\nserver-id=2");
  }

}
