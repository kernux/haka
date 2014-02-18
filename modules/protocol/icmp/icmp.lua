-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local ipv4 = require("protocol/ipv4")

local icmp_dissector = haka.dissector.new{
	type = haka.dissector.EncapsulatedPacketDissector,
	name = 'icmp'
}

icmp_dissector.grammar = haka.grammar.record{
	haka.grammar.field('type',     haka.grammar.number(8)),
	haka.grammar.field('code',     haka.grammar.number(8)),
	haka.grammar.field('checksum', haka.grammar.number(16))
		:validate(function (self)
			self.checksum = 0
			self.checksum = self._payload:inet_checksum()
		end),
	haka.grammar.field('payload',  haka.grammar.bytes())
}:compile()

function icmp_dissector.method:parse_payload(pkt, payload, init)
	self.ip = pkt
	icmp_dissector.grammar:parseall(payload:sub(), self, init)
end

function icmp_dissector.method:verify_checksum()
	return self._payload:inet_checksum() == 0
end

function icmp_dissector.method:forge_payload(pkt, payload)
	if payload.modified then
		self.checksum = nil
	end

	self:validate()
end

function icmp_dissector:create(pkt, init)
	pkt.payload:pos(0):insert(haka.vbuffer(8))
	pkt.proto = 1

	local icmp = icmp_dissector:new(pkt)
	icmp:parse(pkt, init)
	return icmp
end

ipv4.register_protocol(1, icmp_dissector)
