class kbp_powerdns::master {
	include powerdns::master

	Ferm::Rule <<| tag == "ferm_bind_rule_${environment}" |>>
	Ferm::Rule <<| tag == "ferm_poweradmin_rule_${environment}" |>>
}
