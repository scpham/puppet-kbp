class kbp_cassandra::server {
	Ferm::New::Rule <<| tag == "ferm_cassandra_rule_JMX_${environment}" |>>
	Ferm::New::Rule <<| tag == "ferm_cassandra_rule_cluster_${environment}" |>>
	Ferm::New::Rule <<| tag == "ferm_cassandra_rule_client_${environment}" |>>
}
