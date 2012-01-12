define kbp_ssl::public_key($source=false, $content=false) {
  if ! ($source or $content) {
    fail("Public key ${name} has neither a \$source nor a \$content.")
  }
  if $source and $content {
    fail("Public key ${name} has both a \$source and a \$content, only one can be used.")
  }

  kfile { "/etc/ssl/certs/${name}.pem":
    content => $content ? {
      false   => undef,
      default => $content,
    },
    source => $source ? {
      false   => undef,
      default => $source,
    },
    mode   => 444;
  }
}

define kbp_ssl::private_key($source=false, $content=false) {
  if ! ($source or $content) {
    fail("Private key ${name} has neither a \$source nor a \$content.")
  }
  if $source and $content {
    fail("Private key ${name} has both a \$source and a \$content, only one can be used.")
  }

  kfile { "/etc/ssl/private/${name}.content":
    content => $content ? {
      false   => undef,
      default => $content,
    },
    source => $source ? {
      false   => undef,
      default => $source,
    },
    mode   => 400;
  }
}
