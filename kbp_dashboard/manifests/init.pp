class kbp_dashboard::site_host($url, $ssl=true, $dbpassword, $dbhost) {
  include gen_base::python_django_south

  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  Kbp_dashboard::Environment <<| |>> {
    url         => $url,
    port        => $port,
  }

  kbp_mysql::client { 'dashboard':; }

  @@mysql::server::db { "dashboard for ${fqdn}":
    tag => "mysql_${environment}_${custenv}";
  }

  @@mysql::server::grant {
    "dashboard on puppet for ${fqdn}":
      user        => 'dashboard',
      db          => 'puppet',
      hostname    => $fqdn,
      password    => $dbpassword,
      permissions => 'SELECT',
      tag         => "mysql_${environment}_${custenv}";
    "dashboard on dashboard for ${fqdn}":
      user        => 'dashboard',
      db          => 'dashboard',
      hostname    => $fqdn,
      password    => $dbpassword,
      tag         => "mysql_${environment}_${custenv}";
  }

  kcron { 'filldashboarddb':
    ensure  => 'absent',
    command => "/srv/django/dashboard.kumina.nl/dashboard/fill_dashboard_database -ps ${dbhost} -pp ${dbpassword} -ds ${dbhost} -dp ${dbpassword} >/dev/null",
    minute  => 0;
  }
}

define kbp_dashboard::environment($url, $port) {
  kbp_apache::vhost_addition { "${url}/proxies_${name}":
    ports   => $port,
    content => template('kbp_dashboard/vhost-additions/proxies');
  }
}
