class kbp_user::environment {
  Kbp_user::Hashfragment <<| tag == "generic_htpasswd" |>>
}

define kbp_user($uid, $gid, $comment, $groups=false, $keys=false) {
  user { $name:
    uid        => $uid,
    gid        => $gid,
    groups     => $groups ? {
      false   => undef,
      default => $groups,
    },
    comment    => $comment,
    managehome => true,
    require    => Group[$gid];
  }

  if $keys {
    kbp_user::expand_keys { $keys:
      user => $name;
    }
  }
}

define kbp_user::expand_keys {
  ssh_authorized_key { "${user}_${comment}":
    user => $user,
    key  => $name,
    type => "ssh-rsa";
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
