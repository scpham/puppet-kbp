class kbp_php5_xdebug {
  include gen_php5::common

  if $lsbmajdistrelease > 5 {
    $squeeze_or_newer = true
  } else {
    $squeeze_or_newer = false
  }

  kpackage { "php5-xdebug":
    ensure => latest;
  }

  kfile { "/etc/php5/conf.d/xdebug.ini":
    content => $squeeze_or_newer ? {
      true  => "zend_extension=/usr/lib/php5/20090626/xdebug.so\nxdebug.remote_enable=On\nhtml_errors=On\n",
      false => "zend_extension=/usr/lib/php5/20060613/xdebug.so\nxdebug.remote_enable=On\nhtml_errors=On\n",
    },
    require => Package["php5-common"],
    notify  => Exec["reload-apache2"];
  }
}
