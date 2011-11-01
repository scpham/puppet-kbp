class kbp_backup::client($method="offsite") {
  case $method {
    "offsite": { include offsitebackup::client }
    "local":   { include localbackup::client }
    default: {
      fail { "Invalid method (${method}) for kbp_backup::client":; }
    }
  }
}
