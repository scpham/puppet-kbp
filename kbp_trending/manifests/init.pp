class kbp_trending {
}

class kbp_trending::puppetmaster ($method="munin") {
    if $method == "munin" {
        include kbp-munin::client::puppetmaster
    }
}

class kbp_trending::mysql ($method="munin") {
    if $method == "munin" {
        include kbp-munin::client::mysql
    }
}
