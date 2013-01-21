class kbp_dashboard::site_host($url, $ssl=true, $dbpassword, $dbhost, $setup_login=true) {
  include gen_base::python_django_south

  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  if $setup_login {
    file { "/srv/www/${url}/.htpasswd":
      ensure  => link,
      target  => "/srv/www/${url}/${environment}/.htpasswd";
    }
  }

  Kbp_dashboard::Environment <<| |>> {
    url         => $url,
    port        => $port,
    setup_login => $setup_login,
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

  kbp_apache::vhost_addition { "${url}/access":
    ports   => $port,
    content => template('kbp_dashboard/vhost-additions/base_access');
  }

  kcron { 'filldashboarddb':
    command => "/srv/django/dashboard.kumina.nl/dashboard/fill_dashboard_database -ps ${dbhost} -pp ${dbpassword} -ds ${dbhost} -dp ${dbpassword} >/dev/null",
    minute  => 0;
  }
}

define kbp_dashboard::environment($url, $port, $setup_login) {
  file { "/srv/www/${url}/${name}":
    ensure  => directory;
  }

  if $setup_login {
    concat { "/srv/www/${url}/${name}/.htpasswd":
      require => File["/srv/www/${url}/${name}"];
    }

    Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
      target => "/srv/www/${url}/${name}/.htpasswd",
    }
  }

  kbp_apache::vhost_addition {
    "${url}/access_${name}":
      ports   => $port,
      content => template('kbp_dashboard/vhost-additions/access');
    "${url}/proxies_${name}":
      ports   => $port,
      content => template('kbp_dashboard/vhost-additions/proxies');
  }
}
