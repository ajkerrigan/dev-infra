client
dev tun
proto udp
remote asdfa.${dns_name} 443
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verb 3
<ca>
${server_cert}
</ca>

<cert>
${client_cert}
</cert>

<key>
${client_key}
</key>


reneg-sec 0
