define kbp_backup::client($method="offsite", $backup_server="backup.kumina.nl", $backup_home="/backup/${environment}", $backup_user=$environment, $backup_remove_older_than="30B") {
  case $method {
    "offsite": {
      class { "offsitebackup::client":
        backup_server            => $backup_server,
        backup_home              => $backup_home,
        backup_user              => $backup_user,
        backup_remove_older_than => $backup_remove_older_than;
      }
    }
    "local":   {
      class { "localbackup::client":; }
    }
    default:   {
      fail("Invalid method (${method}) for kbp_backup::client")
    }
  }

  kfile { "/etc/backup/includes":
    content => "/\n",
    require => Kpackage["offsite-backup"];
  }

  concat { "/etc/backup/excludes":
    require => Kpackage["offsite-backup"];
  }

  kbp_backup::exclude { "excludes_base":
    content => template("kbp_backup/excludes_base");
  }
}

define kbp_backup::exclude($content=false) {
  concat::add_content { $name:
    content => $content,
    target  => "/etc/backup/excludes";
  }
}
