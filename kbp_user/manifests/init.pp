class kbp_user::environment {
	Kbp_user::Hashfragment <<| tag == "generic_htpasswd" |>>
}

define kbp_user::hashfragment($hash) {
	@@concat::add_content { "${hash}_${environment}":
		content => $hash,
		tag     => $environment ? {
			"kumina" => ["htpasswd","htpasswd_${environment}"],
			default  => "htpasswd_${environment}",
		};
	}
}
