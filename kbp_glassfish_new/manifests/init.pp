# Author: Kumina bv <support@kumina.nl>

class kbp_glassfish_new {
  include gen_glassfish

  group { 'glassfish':
    gid     => 2000,
    require => Package['glassfish'];
  }

  user { 'glassfish':
    uid         => "2000",
    gid         => "glassfish",
    managehome  => false,
    require     => [Package['glassfish'], Group['glassfish']]
  }

  setfacl {
    "Directory permissions on /srv/glassfish for user glassfish":
      dir     => "/srv/glassfish",
      acl     => "default:user:glassfish:rwx",
      require => File['/srv/glassfish'];
    "Directory permissions on /srv/glassfish for group glassfish":
      dir => "/srv/glassfish",
      acl => "default:group:glassfish:rwx",
      require => File['/srv/glassfish'];
  }

  kfile {
    ['/srv/glassfish','/srv/glassfish/domains']:
      ensure  => directory,
      owner   => 'glassfish',
      group   => 'glassfish',
      mode    => 775,
      require => User['glassfish'];
    '/opt/glassfish/domains':
      ensure  => link,
      target  => '/srv/glassfish/domains',
      owner   => 'glassfish',
      group   => 'glassfish',
      force   => true,
      require => [File['/srv/glassfish/domains'],Package['glassfish']];
    }
}

class kbp_glassfish_new::cluster {
  include kbp_glassfish_new

  kfile {
    "/srv/glassfish/nodes":
      ensure  => directory,
      owner   => 'glassfish',
      group   => 'glassfish',
      mode    => 775,
      require => Package['glassfish'];
    "/opt/glassfish/nodes":
      ensure  => link,
      target  => '/srv/glassfish/nodes',
      owner   => 'glassfish',
      group   => 'glassfish',
      mode    => 775,
      require => Package['glassfish'];
  }
}

# Define: kbp_glassfish_new::domain
#
# Actions:
#  Undocumented
#
# Parameters:
#  portbase
#   The portbase value determines where the port assignment should start. See gen_glassfish::domain for more info
#  ensure
#   Either running or stopped (for now...)
#  autostart
#   Should this domain bestarted on boot and when invoking /etc/init.d/glassfish start
#  web_servername
#   Set this to the server name if you need an apache in front of this glassfish
#  web_serveralias
#   An array of server aliases
#  web_port
#   The port we should listen on (keep it at 80)
#  web_sslport
#   Either false or 443 (SSL not implemented yet in this define)
#  web_redundant
#   Is this domain redundant (i.e. is there another server with the same domain that is possibly behind the same loadbalancer)
#  XXX Rutger, dit is niet ge-implementeerd... is dit nodig?
#  java_monitoring
#   Should we monitor the JVM?
#  java_servicegroups
#   Which Icinga service groups will recieve alerts from the JVM monitoring
#  monitoring_sms
#   Should we send SMSes when there is something wrong with this domain?
#  monitoring_statuspath
#   Where can we find status.html
#  mbean_objectname
#   
#  mbean_attributename
#   
#  mbean_expectedvalue
#   
#  mbean_attributekey
#   
#
# Depends:
#  gen_puppet
#  gen_glassfish::domain
#
define kbp_glassfish_new::domain($portbase,
    $web_servername=false, $web_serveralias = [], $web_port = "80", $web_sslport = false, $web_redundant=false,
    $java_monitoring=false, $java_servicegroups=false, $monitoring_sms=true, $monitoring_statuspath=false,
    $mbean_objectname=false, $mbean_attributename=false, $mbean_expectedvalue=false, $mbean_attributekey=false) {

  $jmxport   = $portbase + 86

  $autostart = $name in split($glassfish_autostart_domains, ',')
  gen_glassfish::domain { $name:
    portbase  => $portbase,
    ensure    => $autostart? {
      true    => 'running',
      default => undef,
    };
  }

  # Override this require, as we want domains to be in /srv/glassfish/domains
  Exec <| title == "Create glassfish domain ${name}" |> {
    require => File['/srv/glassfish/domains'],
    creates => "/srv/glassfish/domains/${name}",
  }

  Kfile <| title == "Glassfish domain ${name} autostart" |> {
    path    => "/opt/glassfish/domains/${name}/autostart",
    require => File["/srv/glassfish/domains/${name}"],
  }

  kfile { "/srv/glassfish/domains/${name}":
    ensure  => directory,
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => 755,
    require => Exec["Create glassfish domain ${name}"];
  }

  if $web_servername { # We want an Apache in front of it.
    # Portbase +10 is unused.. let's use it as jk port.
    $jkport = $portbase + 10

    kaugeas { "JK listener for ${name}":
      file    => "/srv/glassfish/domains/${name}/config/domain.xml",
      lens    => "Xml.lns",
      changes => ["set domain/configs/config[#attribute/name = 'server-config']/network-config/network-listeners/network-listener[#attribute/name = 'jk-connector']/#attribute/name 'jk-connector'",
                  "set domain/configs/config[#attribute/name = 'server-config']/network-config/network-listeners/network-listener[#attribute/name = 'jk-connector']/#attribute/port '${jkport}'",
                  "set domain/configs/config[#attribute/name = 'server-config']/network-config/network-listeners/network-listener[#attribute/name = 'jk-connector']/#attribute/protocol 'jk-connector'",
                  "set domain/configs/config[#attribute/name = 'server-config']/network-config/network-listeners/network-listener[#attribute/name = 'jk-connector']/#attribute/transport 'tcp'",
                  "set domain/configs/config[#attribute/name = 'server-config']/network-config/network-listeners/network-listener[#attribute/name = 'jk-connector']/#attribute/thread-pool 'jk-connector'",
                  "set domain/configs/config[#attribute/name = 'server-config']/network-config/network-listeners/network-listener[#attribute/name = 'jk-connector']/#attribute/jk-enabled 'true'",
                  "set domain/configs/config[#attribute/name = 'server-config']/network-config/network-listeners/network-listener[#attribute/name = 'jk-connector']/#attribute/address '127.0.0.1'"
                 ],
     require => Exec["Create glassfish domain ${name}"];
    }

    kbp_monitoring::glassfish { "${name}":
      statuspath => $statuspath ? {
        false   => undef,
        default => $statuspath,
      },
      webport    => $web_port;
    }

    kbp_glassfish_new::domain::site { $web_servername:
      glassfish_domain => $name,
      jkport           => $jkport,
      require          => Augeas["JK listener for ${name}"];
    }
  } else {
    kbp_monitoring::mbean_value { "${name}":
      jmxport       => $jmxport,
      objectname    => $mbean_objectname,
      attributename => $mbean_attributename,
      expectedvalue => $mbean_expectedvalue,
      attributekey  => $mbean_attributekey ? {
        false   => undef,
        default => $mbean_attributekey,
      },
      customname    => "Glassfish ${name} status";
    }
  }

  if $java_monitoring {
    kbp_monitoring::java { "${name}_${jmxport}":
      servicegroups  => $java_servicegroups ? {
        false   => undef,
        default => $java_servicegroups,
      },
      sms            => $sms;
    }
  }

  kbp_trending::glassfish { "${name}":
      jmxport => $jmxport;
  }
}

# Define: kbp_glassfish_new::monitoring::icinga::site
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_glassfish_new::monitoring::icinga::site () {
  kbp_icinga::host { $name:; }

  kbp_icinga::site { $name:
    service_description => "Glassfish domain ${name}",
    host_name           => $name;
  }
}

define glassfish_new::domain::site ($glassfish_domain, $jkport) {
    kbp_apache_new::site { $name:
      glassfish_domain         => $glassfish_domain,
      glassfish_connector_port => $jkport,
      create_documentroot      => false;
    }
}
