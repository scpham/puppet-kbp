define kbp_backup::client($method="offsite") {
  $package = $method ? {
    "offsite" => "offsitebackup::client",
    "local"   => "localbackup::client",
    default   => fail("Invalid method (${method}) for kbp_backup::client"),
  }

  include $package

  kfile { "/etc/backup/includes":
    content => "/",
    require => Kpackage["offsite-backup"];
  }

  concat { "/etc/backup/excludes":
    require => Kpackage["offsite-backup"];
  }

  concat::add_content { "excludes/base":
    content => template("kbp_backup/excludes_base"),
    target  => "/etc/backup/excludes";
  }
}
