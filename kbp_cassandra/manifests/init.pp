class kbp_cassandra::server {
	Ferm::Rule <<| tag == "ferm_cassandra_rule_JMX_${environment}" |>>
	Ferm::Rule <<| tag == "ferm_cassandra_rule_cluster_${environment}" |>>
	Ferm::Rule <<| tag == "ferm_cassandra_rule_client_${environment}" |>>
	Ferm::Rule <<| tag == "ferm_cassandra_rule_monitoring" |>>
}
