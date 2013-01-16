# Author: Kumina bv <support@kumina.nl>

# Class: kbp_php5::curl
#
# Actions:
#  Install curl extensions for PHP5.
#
# Depends:
#  gen_puppet
#
class kbp_php5::curl {
  class { "gen_php5::curl":
    notify => Exec["reload-apache"];
  }
}

class kbp_php5::apc($shm_size=64, $ttl=3600) {
  class { 'gen_php5::apc':
    shm_size => $shm_size,
    ttl      => $ttl;
  }

  file { '/var/www/apc_info.php':
    ensure => symlink,
    target => '/usr/share/munin/plugins/kumina/apc_info.php';
  }

  gen_munin::client::plugin { ['php_apc_files', 'php_apc_fragmentation', 'php_apc_hit_miss', 'php_apc_purge', 'php_apc_rates', 'php_apc_usage', 'php_apc_mem_size', 'php_apc_user_hit_miss', 'php_apc_user_entries', 'php_apc_user_rates']:
    script_path => '/usr/share/munin/plugins/kumina',
    script      => 'php_apc_';
  }

  gen_munin::client::plugin::config { 'php_apc':
    section => 'php_apc_*',
    content => "env.url http://127.0.0.255/apc_info.php?auto\n";
  }
}

# Define: kbp_php5::config
#
# Actions:
#
define kbp_php5::config ($ensure='present', $value=false, $variable=false) {
  gen_php5::common::config { $name:
    ensure   => $ensure,
    value    => $value,
    variable => $variable;
  }

  if $name == 'upload_max_filesize' {
    file { '/etc/apache2/conf.d/fcgi_max_requestlength':
      content => "<IfModule mod_fcgid.c>\nFcgidMaxRequestLen ${value}\n</IfModule>\n";
    }
  }

  if $name == 'post_max_size' {
    kbp_php5::config { 'upload_max_filesize':
      ensure   => $ensure,
      value    => $value;
     }
  }
}
