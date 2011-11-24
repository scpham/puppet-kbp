# Author: Kumina bv <support@kumina.nl>

# Class: kbp_rabbitmq
#
# Actions:
#  Setup a specific version of rabbitmq and deploy some config for it.
#
# Depends:
#  gen_rabbitmq
#  gen_puppet
#
class kbp_rabbitmq($rabbitmq_name=false, $port=5672, $ssl_cert=false, $ssl_key=false, $ssl_port=5671, $namespace='/', $aqmp=false, $stomp=false) {
  $real_class = $stomp ? {
    true  => "gen_rabbitmq::stomp",
    false => $aqmp ? {
      true  => "gen_rabbitmq::aqmp",
      false => "gen_rabbitmq",
    }
  }
  $real_tag = $rabbitmq_name ? {
    false   => "rabbitmq_${environment}",
    default => "rabbitmq_${environment}_${rabbitmq_name}",
  }

  class { $real_class:
    ssl_cert => $ssl_cert,
    ssl_key  => $ssl_key,
    ssl_port => $ssl_port,
  }
  class { "kbp_icinga::rabbitmqctl":
    namespace => $namespace;
  }

  Gen_ferm::Rule <<| tag == $real_tag |>> {
    dport => $ssl_cert ? {
      false   => $port,
      default => "(${port} ${ssl_port})",
    },
    proto  => "tcp",
    action => "ACCEPT",
  }
}

# Class: kbp_rabbitmq::client
#
# Actions:
#  Export the firewall rules we need so we can access the server.
#
# Depends:
#  gen_ferm
#  gen_puppet
#
class kbp_rabbitmq::client($rabbitmq_name=false) {
  @@gen_ferm::rule { "Connections to RabbitMQ for ${fqdn}":
    saddr => $fqdn,
    tag   => $rabbitmq_name ? {
      false   => "rabbitmq_${environment}",
      default => "rabbitmq_${environment}_${rabbitmq_name}",
    };
  }
}

class kbp_rabbitmq::mcollective($pass_client=$pass_server, $pass_server=$pass_client, $rabbitmq_name=false) {
  class { "kbp_rabbitmq":
    rabbitmq_name => $rabbitmq_name,
    port          => 6163,
    stomp         => true;
  }

  $user_client = "mcollective_client"
  $user_server = "mcollective_server"

  gen_rabbitmq::add_user {
    $user_client:
      password => $pass_client;
    $user_server:
      password => $pass_server;
  }

  gen_rabbitmq::set_permissions {
    "permissions for ${user_client}":
      username => $user_client;
#      conf     => "\"^amq-gen-.*\"";
    "permissions for ${user_server}":
      username => $user_server;
#      conf     => "\"^amq-gen-.*\"";
  }

  @@concat::add_content {
    "1 ${user_client} creds":
      content => template("kbp_rabbitmq/mcollective_client.cfg_connections"),
      target  => "/etc/mcollective/client.cfg";
    "1 ${user_server} creds":
      content => template("kbp_rabbitmq/mcollective_server.cfg_connections"),
      target  => "/etc/mcollective/server.cfg";
  }
}
