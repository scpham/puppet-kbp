class kbp_django {
  include gen_django
  include gen_base::libapache2-mod-wsgi
  include gen_base::libjs_jquery

  file { "/srv/django":
    ensure => directory;
  }

  kbp_apache::module { "wsgi":
    require => Package["libapache2-mod-wsgi"];
  }
}

define kbp_django::site($settings='settings', $root_path='/', $root_django="/${name}", $static_path='/media', $static_django="/${name}/media", $auth=false, $wildcard=false, $intermediate=false, $monitor=true, $make_default=false,
    $serveralias=false, $monitor_path=false, $address='*', $monitor_ip=false, $monitor_statuscode=false) {
  include kbp_django

  kbp_apache::site { $name:
    address            => $address,
    auth               => $auth,
    wildcard           => $wildcard,
    intermediate       => $intermediate,
    monitor            => $monitor,
    make_default       => $make_default,
    serveralias        => $serveralias,
    monitor_path       => $monitor_path,
    monitor_ip         => $monitor_ip,
    monitor_statuscode => $monitor_statuscode;
  }

  if $wildcard or $intermediate {
    $real_ssl = true
  }

  kbp_apache::vhost_addition { "${name}/django":
    ports   => $real_ssl ? {
      true    => 443,
      default => undef,
    },
    content => template("kbp_django/vhost-additions/django");
  }

  file {
    "/srv/django${root_django}":
      ensure  => directory,
      mode    => 775;
    "/srv/django${root_django}/dispatch.wsgi":
      content => template("kbp_django/dispatch.wsgi"),
      replace => false,
      mode    => 775;
  }

  if ! defined(File["/srv/django${static_django}"]) {
    file { "/srv/django${static_django}":
      ensure  => directory,
      mode    => 775;
    }
  }
}
