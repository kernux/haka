local arg = {...}

haka.app.install("packet", haka.module.load("packet-pcap", "-f", arg[2], "-o", arg[3]))

haka.log.setlevel(haka.log.DEBUG)

haka.app.load_configuration(arg[1])