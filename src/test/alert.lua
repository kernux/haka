
local ipv4 = require('protocol/ipv4')

haka.rule {
	hooks = { 'ipv4-up' },
	eval = function (self, pkt)
		local myalert = haka.alert{
			start_time = pkt.raw.timestamp,
			end_time = pkt.raw.timestamp,
			description = string.format("filtering IP %s", pkt.src),
			severity = 'medium',
			confidence = 7,
			completion = 'failed',
			method = {
				description = "packet sent on the network",
				ref = { "cve/255-45", "http://...", "cwe:dff" }
			},
			sources = { haka.alert.address(pkt.src, "local.org", "blalvla", 33), haka.alert.service(22, "ssh") },
			targets = { haka.alert.address(ipv4.network(pkt.dst, 22)), haka.alert.address(pkt.dst) },
		}
		
		haka.alert.update(myalert, {
			severity = 'high',
			description = string.format("filtering IP %s", pkt.src),
			confidence = 'low',
			method = {
				ref = "cve/255-45"
			},
			ref = { myalert }
		})
	end
}