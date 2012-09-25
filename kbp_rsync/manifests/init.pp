# Class: kbp_rsync
#
# Action:
#  Installing rsync.
#
# Depends:
#  gen_base
#
class kbp_rsync {
  include gen_base::rsync
}

# Define: kbp_rsync::server
#
# Action:
#   Setup acces for cliens to sync from this server.
#
# Parameters:
#   name: The name of the sync, should be the same as the kbp_rsync::client resource that comes with this.
#
# Depends:
#  kbp_rsync
#
class kbp_rsync::server {
  include kbp_rsync

  Kbp_rsync::Source_setup <<| tag = "${environment}_rsync_${name}" |>>
}

# Define: kbp_rsync::source_setup
#
# Action:
#  Setup an rsync source location. Always uses root.
#
# Parameters:
#  name:   Used for filename and rsyncd section
#  source: The IP of the source machine
#  key:    The key to use for this resource
#  path:   The path to serve for this location
#
# Depends:
#  kbp_rsync
#
define kbp_rsync::source_setup ($source, $key, $path) {
  include kbp_rsync

  kfile { "/root/${name}.conf":
    content => template('kbp_rsync/rsyncd.conf'),
  }

  ssh_authorized_key { "Rsync_user_for_${name}":
    type    => "ssh-rsa",
    user    => "root",
    options => ["from=\"${source}\"","command=\"/usr/bin/rsync --config=/root/${name}.conf --server --daemon .\""],
    key     => $key,
  }
}

# Define: kbp_rsync::client
#
# Action:
#  Setup a client for an rsync job. This should be done on the machine which receives the sync, as in, the target.
#
# Parameters:
#  source_host: The host that the data should be pulled from.
#  target_dir:  The target directory on the local machine to which the data should be synced.
#  source_dir:  The source directory on the source host from which to sync the data to the target dir on the local machine.
#  private_key: The private key of the SSH keypair to use for this. This should be generated and pasted in here, to allow us to setup the connection securely.
#               I don't really see a nicer way of doing this.
#  public_key:  The public key generated from the private key above. Used to setup the connection on the source host.
#  hour:        The cron hour parameter for the cronjob that actually performs the sync. Defaults to *, meaning every hour.
#  minute:      The cron minute parameter for the cronjob that actually performs the sync. Defaults to */5, meaning every 5 minutes.
#  bwlimit:     If you'd like to limit the bandwidth used for this sync, you can use this. The number is is kbit/s (as opposed to the rsync bwlimit, which
#               requires a totally inconvenient KBytes/s).
#  target_ip:   The IP address of the target machine, this machine. Defaults to the external ip address as found by the fact.
#
# Example:
#  This is an example on how to generate the ssh key:
#
#   $ ssh-keygen -b 2048 -t rsa -N '' -f outkey
#
#  Private key is in the file 'outkey', public key is in the file 'outkey.pub'.
#
# Depends:
#  kbp_rsync
#  kcron
#
define kbp_rsync::client ($source_host, $target_dir, $source_dir, $private_key, $public_key, $hour="*", $minute="*/5", bwlimit=false, $target_ip=$::external_ipaddress, $exclude=false) {
  # We prefer entering the bwlimit in kbit/s, so we need to convert it to
  # KBytes/s
  if $bwlimit {
    $tmp_bwlimit = $bwlimit / 8
    $real_bwlimit = "--bwlimit ${tmp_bwlimit}"
  } else {
    # Just don't set the option
    $real_bwlimit = ""
  }

  # Custom exclude parameters
  if $exclude {
    $real_exclude = "--exclude ${exclude}"
  } else {
    $real_exclude = ""
  }

  # Setup the secret key
  file {
    "/root/.ssh":
      ensure  => directory,
      mode    => 700;
    "/root/.ssh/rsync-key-${name}":
      content => $private_key;
  }

  # The cronjob that does the actual sync
  kcron { "Sync from other machine":
    command => "/usr/bin/rsync -qazHSx --delete ${real_bwlimit} ${real_exclude} -e 'ssh -i /root/.ssh/rsync-key-${name}' ${source_host}::${name}/* ${target_dir}",
    user    => "root",
    hour    => $hour,
    minute  => $minute,
  }

  # Export the setup
  @@kbp_rsync::source_setup { $name:
    source => $target_ip,
    key    => $public_key,
    path   => $source_dir,
    tag    => "${environment}_rsync_${name}",
  }
}
