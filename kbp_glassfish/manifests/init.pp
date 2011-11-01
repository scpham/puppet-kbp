# Author: Kumina bv <support@kumina.nl>

# Define: kbp_glassfish::domain
#
# Parameters:
#  jmxport
#    Undocumented
#  webport
#    Undocumented
#  java_monitoring
#    Undocumented
#  java_servicegroups
#    Undocumented
#  sms
#    Define whether to send out monitoring sms
#  statuspath
#    Undocumented
#  adminport
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_glassfish::domain($adminport, $jmxport, $webport=false, $java_monitoring=false, $java_servicegroups=false, $sms=true,
    $statuspath=false, $objectname=false, $attributename=false, $expectedvalue=false, $attributekey=false) {
  gen_ferm::rule {
    "Glassfish admin panel for ${name}":
      proto  => "tcp",
      dport  => $adminport,
      action => "ACCEPT",
      tag    => "glassfish_admin_${environment}";
    "Glassfish JMX port for ${name}":
      proto  => "tcp",
      dport  => $jmxport,
      action => "ACCEPT",
      tag    => "glassfish_jmx_${environment}";
  }

  if $webport {
    gen_ferm::rule { "Glassfish web for ${name}":
      proto  => "tcp",
      dport  => $webport,
      action => "ACCEPT",
      tag    => "glassfish_web_${environment}";
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

  if $webport and !$objectname {
    kbp_monitoring::glassfish { "${name}":
      statuspath => $statuspath ? {
        false   => undef,
        default => $statuspath,
      },
      webport    => $webport;
    }
  } elsif $objectname {
    kbp_monitoring::mbean_value { "${name}":
      jmxport       => $jmxport,
      objectname    => $objectname,
      attributename => $attributename,
      expectedvalue => $expectedvalue,
      attributekey  => $attributekey ? {
        false   => undef,
        default => $attributekey,
      },
      customname    => "Glassfish ${name} status";
    }
  }

  if $jmxport {
    kbp_trending::glassfish { "${name}":
      jmxport => $jmxport;
    }
  }
}

# Define: kbp_glassfish::site
#
# Parameters:
#  serveralias
#    Undocumented
#  with_ssl
#    Undocumented
#  port
#    Undocumented
#  sslport
#    Undocumented
#  redundant
#    Undocumented
#  domain
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_glassfish::site($domain = "domain1", $serveralias = [], $with_ssl = false, $port = "80", $sslport = "443", $redundant=true) {
  if $domain != "domain1" and !$redundant {
    kbp_glassfish::monitoring::icinga::site { $name:; }

    kbp_smokeping::target { $name:; }
  }
}

# Define: kbp_glassfish::monitoring::icinga::site
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_glassfish::monitoring::icinga::site () {
  kbp_icinga::host { $name:; }

  kbp_icinga::site { $name:
    service_description => "Glassfish domain ${name}",
    host_name           => $name;
  }
}
