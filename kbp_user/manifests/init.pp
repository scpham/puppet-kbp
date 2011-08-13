class kbp_user::environment {
	Kbp_user::Hashfragment <<| tag == "kumina_htpasswd" |>>
}

define kbp_user::hashfragment($hash) {
	@@concat::add_content { "${hash}_${environment}":
		content => $hash,
		tag     => ["htpasswd","htpasswd_${environment}"];
	}
}
