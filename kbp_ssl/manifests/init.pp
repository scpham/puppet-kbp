define kbp_ssl::wildcard {
  $key_name = regsubst($name,'^(.*)/(.*)$','\2')

  kbp_icinga::sslcert { $key_name:; }

  kbp_ssl::keys { $name:; }
}

define kbp_ssl::keys {
  $key_name = regsubst($name,'^(.*)/(.*)$','\2')

  kbp_ssl::private_key { $key_name:
    key_location => "${name}.key";
  }

  kbp_ssl::public_key { $key_name:
    key_location => "${name}.pem";
  }
}

define kbp_ssl::public_key($content=false, $key_location=false) {
  file { "/etc/ssl/certs/${name}.pem":
    content => $content ? {
      false   => template($key_location),
      default => $content,
    },
    mode    => 444;
  }
}

define kbp_ssl::private_key($content=false, $key_location=false) {
  file { "/etc/ssl/private/${name}.key":
    content => $content ? {
      false   => template($key_location),
      default => $content,
    },
    mode    => 400;
  }
}
