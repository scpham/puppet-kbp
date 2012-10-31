class kbp_php5_xdebug {
  include gen_php5::common

  if $lsbdistcodename != 'lenny' {
    $file_location = "/usr/lib/php5/20090626/xdebug.so"
  } else {
    $file_location = "/usr/lib/php5/20060613/xdebug.so"
  }

  package { "php5-xdebug":
    notify => Exec["reload-apache2"],
    ensure => latest;
  }

  gen_php5::common::config {
    "zend_extension":       value => $file_location;
    "xdebug.remote_enable": value => "On";
    "html_errors":          value => "On";
  }
}

class kbp_php5_xdebug::disable {
  package { "php5-xdebug":
    notify => Exec["reload-apache2"],
    ensure => absent;
  }

  gen_php5::common::config {
    "zend_extension":       ensure => absent;
    "xdebug.remote_enable": ensure => absent;
    "html_errors":          ensure => absent;
  }
}
