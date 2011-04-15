class kbp_trending {
}

class kbp_trending::puppetmaster ($method="munin") {
    if $method == "munin" {
        include kpb-munin::client::puppetmaster
    }
}
