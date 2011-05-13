class kbp_cassandra::server {
	Ferm::Rule <<| tag == "ferm_cassandra_${environment}" |>>
	Ferm::Rule <<| tag == "ferm_cassandra_${environment}_stage" |>>
	Ferm::Rule <<| tag == "ferm_cassandra_monitoring" |>>
}
