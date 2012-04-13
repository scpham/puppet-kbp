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

  Gen_ferm::Rule <<| tag == "bind_${environment}" |>>

  Gen_ferm::Rule <<| tag == "poweradmin_${environment}" |>>

  Gen_ferm::Rule <<| tag == "dns_monitoring" |>>
}

class kbp_powerdns::authoritative::master {
  include gen_powerdns
  include gen_powerdns::backend::mysql
  class { "kbp_mysql::server":
    mysql_name => "powerdns";
  }

#  include kbp_mysql::server::ssl
}

class kbp_powerdns::authoritative::hidden::master ($db_password="pdns") {
  class { "kbp_mysql::master":
    mysql_name => "powerdns";
  }

  file { "/etc/mysql/conf.d/master.cnf":
    content => inline_template("[mysqld]\nserver-id=1\nlog-bin=mysql-bin");
  }

#  mysql::db { "pdns":; }
#  mysql::grant { "Allow pdns user access to pdns database":
#    user     => "pdns",
#    password => $db_password;
#  }

  include kbp_mysql::server::ssl
  #include poweradmin
}


class kbp_powerdns::authoritative::hidden::slave ($db_password="pdns"){
  include gen_powerdns
  class { "gen_powerdns::backend::mysql":
    db_password => $db_password;
  }

  include kbp_mysql::server::ssl
  class { "kbp_mysql::slave":
    mysql_name => "powerdns";
  }

  file { "/etc/mysql/conf.d/slave.cnf":
    content => inline_template("[mysqld]\nserver-id=2");
  }

}
