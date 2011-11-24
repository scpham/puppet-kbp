class kbp_mcollective::server {
  include gen_mcollective::server
  class { "kbp_rabbitmq::client":
    rabbitmq_name => "mcollective";
  }

  kfile { "/etc/mcollective/facts.yaml":
    content => inline_template("<%= scope.to_hash.reject { |k,v| !( k.is_a?(String) && v.is_a?(String) ) }.to_yaml %>"),
    require => Package["mcollective-common"];
  }
}

class kbp_mcollective::client($pass_client, $pass_server) {
  include gen_mcollective::client
  class { "kbp_rabbitmq::mcollective":
    pass_client   => $pass_client,
    pass_server   => $pass_server,
    rabbitmq_name => "mcollective";
  }
}
