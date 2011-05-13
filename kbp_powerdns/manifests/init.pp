class kbp_powerdns::master {
	include powerdns::master

	Ferm::Rule <<| tag == "bind_${environment}" |>>
	Ferm::Rule <<| tag == "poweradmin_${environment}" |>>
}
