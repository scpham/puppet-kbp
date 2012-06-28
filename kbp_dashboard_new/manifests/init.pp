class kbp_dashboard_new::site($url, $ssl=true, $mysql_name=$environment, $dbpassword) {
  include gen::base::python_django_south

  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  file { "/srv/www/${url}/.htpasswd":
    ensure  => link,
    target  => "/srv/www/${url}/kumina/.htpasswd";
  }

  Kbp_dashboard_new::Environment <<| |>> {
    url  => $url,
    port => $port,
  }

  kbp_mysql::client { 'dashboard':
    mysql_name => 'dashboard';
  }

  @@mysql::server::db { "dashboard for ${fqdn}":
    tag => "mysql_${kumina}_dashboard";
  }

  @@mysql::server::grant {
    "dashboard on puppet for ${fqdn}":
      user        => 'dashboard',
      db          => 'puppet',
      hostname    => $fqdn,
      password    => $dbpassword,
      permissions => 'SELECT',
      tag         => "mysql_${kumina}_dashboard";
    "dashboard on dashboard for ${fqdn}":
      user        => 'dashboard',
      db          => 'dashboard',
      hostname    => $fqdn,
      password    => $dbpassword,
      tag         => "mysql_${kumina}_dashboard";
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

define kbp_dashboard_new::environment($env_name, $fullname, $url, $port) {
  file { "/srv/www/${url}/${name}":
    ensure  => directory,
  }

  concat { "/srv/www/${url}/${name}/.htpasswd":
    require => File["/srv/www/${url}/${name}"];
  }

  Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
    target => "/srv/www/${url}/${name}/.htpasswd",
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/access_${name}":
    content => template("kbp_dashboard_new/vhost-additions/access");
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
      undef   => false,
      default => $parent,
    };
  }
}

define kbp_dashboard_new::server($fqdn, $environment, $dcenv, $is_virtual, $proccount, $memsize, $memtype, $parent) {}

define kbp_dashboard_new::interface::wrapper() {
  @@kbp_dashboard_new::interface { $name:
    if_name => $name,
    server  => $fqdn,
    ipv4    => template("kbp_dashboard_new/ipv4"),
    ipv6    => template("kbp_dashboard_new/ipv6"),
    mac     => template("kbp_dashboard_new/mac");
  }
}

define kbp_dashboard_new::interface($if_name, $server, $ipv4, $ipv6, $mac) {}

define kbp_dashboard_new::customer_entry_export($path, $extra_paths=false, $regex_paths=false, $entry_url, $text, $add_environment=true) {
  $entry_name = regsubst($name,'^(.*?) (.*)$','\1')

  if ! defined(Kbp_dashboard_new::Customer_entry["${entry_name}_${environment}"]) {
    @@kbp_dashboard_new::customer_entry { "${entry_name}_${environment}":
      path            => $path,
      extra_paths     => $extra_paths,
      regex_paths     => $regex_paths,
      entry_url       => $entry_url,
      text            => $text,
      add_environment => $add_environment,
      entry_name      => $entry_name,
      environment     => $environment;
    }
  }
}

define kbp_dashboard_new::customer_entry($path, $extra_paths=false, $regex_paths=false, $entry_url, $text, $add_environment=true, $entry_name, $environment) {
  $base_path = $path

  concat::add_content { "1 index.html content for ${entry_name} for ${environment}":
    content => template("kbp_dashboard_new/index.html_customer_body"),
    target  => "/srv/www/${url}/${environment}/index.html";
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/proxy_${entry_name}_${environment}":
    content => template("kbp_dashboard_new/vhost-additions/proxy");
  }
}

define kbp_dashboard_new::base_entry($path, $text, $entry_name, $environment) {
  $base_path = $path

  concat::add_content { "1 index.html content for ${entry_name} for ${environment}_new":
    content => template("kbp_dashboard_new/index.html_customer_body"),
    target  => "/srv/www/${url}/${environment}/index.html";
  }
}
