class kbp_powerdns::master {
	include powerdns::master

	Ferm::New::Rule <<| tag == "ferm_bind_rule_${environment}" |>>
}
