class kbp_dashboard_new::site_host($url, $prod_url, $ssl=true, $dbpassword) {
  include gen_base::python_django_south

  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  file { "/srv/www/${url}/.htpasswd":
    ensure  => link,
    target  => "/srv/www/${prod_url}/.htpasswd";
  }

  kbp_mysql::client { 'dashboard_new':; }

  @@mysql::server::db { "dashboard_new for ${fqdn}":
    tag => "mysql_${environment}_dashboard_new";
  }

  @@mysql::server::grant {
    "dashboard_new on puppet for ${fqdn}":
      user        => 'dashboard_new',
      db          => 'puppet',
      hostname    => $fqdn,
      password    => $dbpassword,
      permissions => 'SELECT',
      tag         => "mysql_${environment}_dashboard_new";
    "dashboard_new on dashboard_new for ${fqdn}":
      user        => 'dashboard_new',
      db          => 'dashboard_new',
      hostname    => $fqdn,
      password    => $dbpassword,
      tag         => "mysql_${environment}_dashboard_new";
  }

  Kbp_dashboard_new::Environment <<| |>> {
    url      => $url,
    prod_url => $prod_url,
    port     => $port,
  }

  kbp_apache::vhost_addition { "${url}/access":
    ports   => $port,
    content => template('kbp_dashboard_new/vhost-additions/base_access');
  }
}

define kbp_dashboard_new::environment($url, $prod_url, $port) {
  file {
    "/srv/www/${url}/${name}":
      ensure  => directory;
    "/srv/www/${url}/${name}/.htpasswd":
      ensure  => link,
      target  => "/srv/www/${prod_url}/${name}/.htpasswd";
  }

  kbp_apache::vhost_addition {
    "${url}/access_${name}":
      ports   => $port,
      content => template('kbp_dashboard_new/vhost-additions/access');
    "${url}/proxies_${name}":
      ports   => $port,
      content => template('kbp_dashboard_new/vhost-additions/proxies');
  }
}
