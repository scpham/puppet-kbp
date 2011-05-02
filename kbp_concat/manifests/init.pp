class kbp_concat {
	include common::concat::setup

	define add_content($target, $content, $order=15, $ensure=present) {
		$body = $content ? {
			false   => $name,
			default => $content,
		}

		concat::fragment{ "${target}_fragment_${name}":
			content => "${body}\n",
			target  => $target,
			order   => $order,
			ensure  => $ensure;
		}
	}
}
