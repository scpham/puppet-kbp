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

define kbp_django::site($settings='settings', $root_path='/', $root_django="/${name}", $static_path='/media', $static_django="/${name}/media", $auth=false, $cert=false, $wildcard=false, $intermediate=false, $monitor=true,
    $make_default=false, $serveralias=false, $monitor_path=false, $address='*', $monitor_ip=false, $monitor_statuscode=false, $wsgi_file='dispatch.wsgi', $wsgi_owner='root') {
  include kbp_django

  kbp_apache::site { $name:
    address            => $address,
    auth               => $auth,
    wildcard           => $wildcard,
    cert               => $cert,
    intermediate       => $intermediate,
    monitor            => $monitor,
    make_default       => $make_default,
    serveralias        => $serveralias,
    monitor_path       => $monitor_path,
    monitor_ip         => $monitor_ip,
    monitor_statuscode => $monitor_statuscode;
  }

  if $wildcard or $intermediate or $cert {
    $real_ssl = true
  }

  kbp_django::app { $name:
    vhost         => $name,
    port          => $real_ssl ? {
      true    => 443,
      default => 80,
    },
    settings      => $settings,
    root_path     => $root_path,
    root_django   => $root_django,
    static_path   => $static_path,
    static_django => $static_django,
    wsgi_file     => $wsgi_file,
    wsgi_owner    => $wsgi_owner;
  }
}

define kbp_django::app($vhost, $port, $settings='settings', $root_path='/', $root_django="/${name}", $static_path='/media', $static_django="/${name}/media", $vhost_addition_prefix='', $wsgi_file='dispatch.wsgi',
    $wsgi_owner='root') {
  kbp_apache::vhost_addition { "${vhost}/${vhost_addition_prefix}django":
    ports   => $port,
    content => template("kbp_django/vhost-additions/django");
  }

  file {
    "/srv/django${root_django}":
      ensure  => directory,
      mode    => 775;
  }

  if $wsgi_file == 'dispatch.wsgi' {
    file { "/srv/django${root_django}/dispatch.wsgi":
      content => template("kbp_django/dispatch.wsgi"),
      owner   => $wsgi_owner,
      replace => false,
      mode    => 775;
    }
  }

  if ! defined(File["/srv/django${static_django}"]) {
    file { "/srv/django${static_django}":
      ensure  => directory,
      mode    => 775;
    }
  }
}
