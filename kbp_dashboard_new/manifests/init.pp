class kbp_dashboard_new::site($url, $prod_url, $ssl=true, $mysql_name=$environment, $dbpassword) {
  include gen_base::python_django_south

  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  file { "/srv/www/${url}/.htpasswd":
    ensure  => link,
    target  => "/srv/www/${prod_url}/.htpasswd";
  }

  Kbp_dashboard_new::Environment <<| |>> {
    url      => $url,
    prod_url => $prod_url,
    port     => $port,
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/access":
    content => template('kbp_dashboard_new/vhost-additions/base_access');
  }
}

class kbp_dashboard_new::client {
  $used_ifs_string = template("kbp_dashboard_new/interfaces")
  $used_ifs        = split($used_ifs_string, ",")

  kbp_dashboard_new::server::wrapper { $fqdn:; }

  kbp_dashboard_new::interface::wrapper { $used_ifs:; }
}

define kbp_dashboard_new::environment::wrapper($fullname) {
  @@kbp_dashboard_new::environment { $name:
    env_name => $name,
    fullname => $fullname;
  }
}

define kbp_dashboard_new::environment($env_name, $fullname, $url, $prod_url, $port) {
  file {
    "/srv/www/${url}/${name}":
      ensure  => directory,
    "/srv/www/${url}/${name}/.htpasswd":
      ensure  => link,
      target  => "/srv/www/${prod_url}/${name}/.htpasswd";
  }

  kbp_apache_new::vhost_addition {
    "${url}_${port}/access_${name}":
      content => template('kbp_dashboard_new/vhost-additions/access');
    "${url}_${port}/proxies_${name}":
      content => template('kbp_dashboard_new/vhost-additions/proxies');
  }
}

define kbp_dashboard_new::dcenv::wrapper($fullname) {
  @@kbp_dashboard_new::dcenv { $name:
    dcenv_name => $name,
    fullname   => $fullname;
  }
}

define kbp_dashboard_new::dcenv($dcenv_name, $fullname) {}

define kbp_dashboard_new::server::wrapper() {
  @@kbp_dashboard_new::server { $name:
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

define kbp_dashboard_new::server($fqdn, $environment, $dcenv, $is_virtual, $proccount, $memsize, $memtype, $parent) {}

define kbp_dashboard_new::interface::wrapper() {
  @@kbp_dashboard_new::interface { "${name}${fqdn}":
    key     => "${name}${fqdn}",
    if_name => $name,
    server  => $fqdn,
    ipv4    => template("kbp_dashboard_new/ipv4"),
    ipv6    => template("kbp_dashboard_new/ipv6"),
    mac     => template("kbp_dashboard_new/mac");
  }
}

define kbp_dashboard_new::interface($key, $if_name, $server, $ipv4, $ipv6, $mac) {}
