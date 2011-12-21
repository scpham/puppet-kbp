class kbp_backup::disable {
  Kbp_backup::Client <| |> {
    ensure => absent,
  }

  Kbp_backup::Exclude <| |> {
    ensure => absent,
  }
}

define kbp_backup::client($ensure="present", $method="offsite", $backup_server="backup.kumina.nl", $backup_home="/backup/${environment}", $backup_user=$environment, $backup_remove_older_than="30B") {
  $real_method = $ensure ? {
    "absent" => "absent",
    default  => $method,
  }

  case $real_method {
    "absent": {}
    "offsite": {
      $package = "offsite-backup"

      class { "offsitebackup::client":
        backup_server            => $backup_server,
        backup_home              => $backup_home,
        backup_user              => $backup_user,
        backup_remove_older_than => $backup_remove_older_than;
      }
    }
    "local":   {
      $package = "local-backup"

      class { "localbackup::client":; }
    }
    default:   {
      fail("Invalid method (${method}) for kbp_backup::client")
    }
  }

  if $ensure == "absent" {
    kfile { "/etc/backup/includes":
      ensure  => $ensure;
    }

    concat { "/etc/backup/excludes":
      ensure  => $ensure;
    }
  } else {
    kfile { "/etc/backup/includes":
      ensure  => $ensure,
      content => "/\n",
      require => Kpackage[$package];
    }

    concat { "/etc/backup/excludes":
      ensure  => $ensure,
      require => Kpackage[$package];
    }
  }

  kbp_backup::exclude { "excludes_base":
    ensure  => $ensure,
    content => template("kbp_backup/excludes_base");
  }
}

define kbp_backup::exclude($ensure="present", $content=false) {
  $sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

  concat::add_content { $sanitized_name:
    ensure  => $ensure,
    content => $content,
    target  => "/etc/backup/excludes";
  }
}
