class kbp_sphinxsearch::server {
	include sphinxsearch::server
	include kbp_sphinxsearch::monitoring::icinga::server

	Ferm::Rule <<| tag == "ferm_sphinxsearch_rule_${environment}" |>>
	Ferm::Rule <<| tag == "ferm_sphinxsearch_rule_monitoring" |>>
}

class kbp_sphinxsearch::monitoring::icinga::server {
	kbp_icinga::service { "spinxsearch_server_${fqdn}":
		service_description => "Sphinxsearch service",
		checkcommand        => "check_tcp",
		argument1           => 3312;
	}
}
