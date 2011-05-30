class kbp_powerdns::master {
	include powerdns::master

	Gen_ferm::Rule <<| tag == "bind_${environment}" |>>

	Gen_ferm::Rule <<| tag == "poweradmin_${environment}" |>>
}
