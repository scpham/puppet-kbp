class kbp_dashboard::site($url, $ssl=true, $mysql_name=$environment, $dbpassword) {
  include gen_base::python_django_south

  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  file { "/srv/www/${url}/.htpasswd":
    ensure  => link,
    target  => "/srv/www/${url}/${environment}/.htpasswd";
  }

  Kbp_dashboard::Environment <<| |>> {
    url  => $url,
    port => $port,
  }

  kbp_mysql::client { 'dashboard':
    mysql_name => 'dashboard';
  }

  @@mysql::server::db { "dashboard for ${fqdn}":
    tag => "mysql_${environment}_dashboard";
  }

  @@mysql::server::grant {
    "dashboard on puppet for ${fqdn}":
      user        => 'dashboard',
      db          => 'puppet',
      hostname    => $fqdn,
      password    => $dbpassword,
      permissions => 'SELECT',
      tag         => "mysql_${environment}_dashboard";
    "dashboard on dashboard for ${fqdn}":
      user        => 'dashboard',
      db          => 'dashboard',
      hostname    => $fqdn,
      password    => $dbpassword,
      tag         => "mysql_${environment}_dashboard";
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/access":
    content => template('kbp_dashboard/vhost-additions/base_access');
  }

  kcron { 'filldashboarddb':
    command => "/srv/django/dashboard.kumina.nl/dashboard/fill_dashboard_database -ps ${dbhost} -pp ${dbpasswd} -ds ${dbhost} -dp ${dbpasswd}",
    hour    => 0;
  }
}

class kbp_dashboard::client {
  $used_ifs_string = template("kbp_dashboard/interfaces")
  $used_ifs        = split($used_ifs_string, ",")

  kbp_dashboard::server::wrapper { $fqdn:; }

  kbp_dashboard::interface::wrapper { $used_ifs:; }
}

define kbp_dashboard::service::wrapper($fullname) {
  @@kbp_dashboard::service { "${name}_${fqdn}":
    key          => "${name}_${fqdn}",
    service_name => $name,
    fullname     => $fullname,
    server       => $fqdn;
  }
}

define kbp_dashboard::service($key, $service_name, $fullname, $server) {}

define kbp_dashboard::service_plugin::wrapper($fullname, $service) {
  @@kbp_dashboard::service { "${name}_${service}_${fqdn}":
    key         => "${name}_${service}_${fqdn}",
    plugin_name => $name,
    fullname    => $fullname,
    service     => $service,
    server      => $fqdn;
  }
}

define kbp_dashboard::service_plugin($key, $plugin_name, $fullname, $service, $server) {}

define kbp_dashboard::environment::wrapper($fullname) {
  @@kbp_dashboard::environment { $name:
    env_name => $name,
    fullname => $fullname;
  }
}

define kbp_dashboard::environment($env_name, $fullname, $url, $port) {
  file { "/srv/www/${url}/${name}":
    ensure  => directory,
  }

  concat { "/srv/www/${url}/${name}/.htpasswd":
    require => File["/srv/www/${url}/${name}"];
  }

  Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
    target => "/srv/www/${url}/${name}/.htpasswd",
  }

  kbp_apache_new::vhost_addition {
    "${url}_${port}/access_${name}":
      content => template('kbp_dashboard/vhost-additions/access');
    "${url}_${port}/proxies_${name}":
      content => template('kbp_dashboard/vhost-additions/proxies');
  }
}

define kbp_dashboard::dcenv::wrapper($fullname) {
  @@kbp_dashboard::dcenv { $name:
    dcenv_name => $name,
    fullname   => $fullname;
  }
}

define kbp_dashboard::dcenv($dcenv_name, $fullname) {}

define kbp_dashboard::server::wrapper() {
  @@kbp_dashboard::server { $name:
    fqdn        => $fqdn,
    environment => $environment,
    dcenv       => $dcenv,
    is_virtual  => $is_virtual,
    proccount   => $processorcount,
    memsize     => regsubst($memorysize, '^(.*) .*$', '\1'),
    memtype     => regsubst($memorysize, '^.* (.*)$', '\1'),
    parent      => $parent ? {
      undef   => 'none',
      default => $is_virtual ? {
        'false' => 'none',
        default => $parent,
      },
    };
  }
}

define kbp_dashboard::server($fqdn, $environment, $dcenv, $is_virtual, $proccount, $memsize, $memtype, $parent) {}

define kbp_dashboard::interface::wrapper() {
  @@kbp_dashboard::interface { "${name}_${fqdn}":
    key     => "${name}_${fqdn}",
    if_name => $name,
    server  => $fqdn,
    ipv4    => template("kbp_dashboard/ipv4"),
    ipv6    => template("kbp_dashboard/ipv6"),
    mac     => template("kbp_dashboard/mac");
  }
}

define kbp_dashboard::interface($key, $if_name, $server, $ipv4, $ipv6, $mac) {}
