class kbp_dashboard_new::site_host($url, $prod_url, $ssl=true, $dbpassword) {
  include gen_base::python_django_south

  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  kbp_mysql::client { 'dashboard_new':; }

  @@mysql::server::db { "dashboard_new for ${fqdn}":
    tag => "mysql_${environment}_${custenv}";
  }

  @@mysql::server::grant {
    "dashboard_new on puppet for ${fqdn}":
      user        => 'dashboard_new',
      db          => 'puppet',
      hostname    => $fqdn,
      password    => $dbpassword,
      permissions => 'SELECT',
      tag         => "mysql_${environment}_${custenv}";
    "dashboard_new on icinga for ${fqdn}":
      user        => 'dashboard_new',
      db          => 'icinga',
      hostname    => $fqdn,
      password    => $dbpassword,
      tag         => "mysql_${environment}_${custenv}";
    "dashboard_new on dashboard_new for ${fqdn}":
      user        => 'dashboard_new',
      db          => 'dashboard_new',
      hostname    => $fqdn,
      password    => $dbpassword,
      tag         => "mysql_${environment}_${custenv}";
  }

  Kbp_dashboard_new::Environment <<| |>> {
    url      => $url,
    prod_url => $prod_url,
    port     => $port,
  }
}

define kbp_dashboard_new::environment($url, $prod_url, $port, $prettyname) {
  kbp_apache::vhost_addition { "${url}/proxies_${name}":
    ports   => $port,
    content => template('kbp_dashboard_new/vhost-additions/proxies');
  }
}
