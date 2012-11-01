define kbp_ssl::keys($owner = 'root') {
  $key_name = regsubst($name,'^(.*)/(.*)$','\2')

  kbp_ssl::private_key { $key_name:
    key_location => "${name}.key",
    owner        => $owner;
  }

  kbp_ssl::public_key { $key_name:
    key_location => "${name}.pem",
    owner        => $owner;
  }
}

define kbp_ssl::public_key($content=false, $key_location=false, $owner = 'root') {
  file { "/etc/ssl/certs/${name}.pem":
    content => $content ? {
      false   => template($key_location),
      default => $content,
    },
    owner   => $owner,
    mode    => 444;
  }

  kbp_icinga::sslcert { $name:; }
}

define kbp_ssl::private_key($key_location=false, $owner = 'root') {
  file { "/etc/ssl/private/${name}.key":
    source => "puppet:///modules/${key_location}",
    owner  => $owner,
    mode   => 400;
  }
}

define kbp_ssl::intermediate {
  $realname = $name ? {
    'kumina'      => 'KuminaCA',
    'positivessl' => 'PositiveSSLCA',
    'rapidssl'    => 'RapidSSL_CA_bundle',
    'terena'      => 'TerenaCA',
    'thawte'      => 'Thawte_SSL_CA',
    'verisign'    => 'verisign_bundle',
    default       => fail("${name} is not a known intermediate."),
  }

  if !defined(Kbp_ssl::Public_key[$realname]) {
    kbp_ssl::public_key { $realname:
      content => template("kbp_ssl/${realname}.pem");
    }
  }
}
