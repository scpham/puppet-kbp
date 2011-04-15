class kbp_trending {
}

class kbp-munin::client::puppetmaster ($method="munin") {
    if $method == "munin" {
        include kpb-munin::client::puppetmaster
    }
}
