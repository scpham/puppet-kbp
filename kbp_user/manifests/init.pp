class kbp_user::environment {
  Kbp_user::Hashfragment <<| tag == "generic_htpasswd" |>>
}

define kbp_user($ensure="present", $uid, $gid, $comment, $groups=false, $shell='/bin/bash', $keys=false, $key_type='ssh-rsa') {
  user { $name:
    ensure     => $ensure,
    uid        => $uid,
    gid        => $gid,
    groups     => $groups ? {
      false   => undef,
      default => $groups,
    },
    shell      => $shell,
    comment    => $comment,
    managehome => true,
    require    => Group[$gid];
  }

  if $keys and $ensure == "present" {
    kbp_user::expand_keys { $keys:
      user => $name,
      type => $key_type;
    }
  }

  if $ensure == "absent" {
    file { "/home/${name}":
      ensure => "absent",
      force  => true;
    }
  }
}

define kbp_user::expand_keys($user, type='ssh-rsa') {
  ssh_authorized_key { "${user}_${name}":
    user => $user,
    key  => $name,
    type => $type;
  }
}

define kbp_user::hashfragment($hash) {
  @@concat::add_content { "${hash}_${environment}":
    content => $hash,
    tag     => $environment ? {
      "kumina" => ["htpasswd","htpasswd_${environment}"],
      default  => "htpasswd_${environment}",
    };
  }
}
