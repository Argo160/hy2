first() {
  clear
  mkdir hy2
  cd hy2
  wget https://github.com/apernet/hysteria/releases/download/app%2Fv2.5.2/hysteria-linux-amd64
  chmod 755 hysteria-linux-amd64  
}
final() {
  clear
cat <<EOL > /etc/systemd/system/hy2.service
[Unit]
After=network.target nss-lookup.target

[Service]
User=root
WorkingDirectory=/root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
ExecStart=/root/hy2/hysteria-linux-amd64 server -c /root/hy2/config.yaml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=5
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOL
systemctl daemon-reload
systemctl enable hy2
systemctl start hy2
systemctl status hy2
}
Iran() {
  clear
  first
  openssl ecparam -genkey -name prime256v1 -out ca.key
  openssl req -new -x509 -days 36500 -key ca.key -out ca.crt  -subj "/CN=bing.com"
  read -p "Enter the Hy2 port :" port
  read -p "Enter obfs password :" obfspass
  read -p "Enter Authentication Pass :" authpass
cat <<EOL > config.yaml
listen: :$port
tls:
  cert: /root/hy2/ca.crt
  key: /root/hy2/ca.key
obfs:
  type: salamander
  salamander:
    password: "$obfspass"
auth:
  type: password
  password: "$authpass"
quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520
  maxIdleTimeout: 60s
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false
bandwidth:
  up: 1 gbps
  down: 1 gbps
ignoreClientBandwidth: false
disableUDP: false
udpIdleTimeout: 60s
resolver:
  type: udp
  tcp:
    addr: 8.8.8.8:53
    timeout: 4s
  udp:
    addr: 8.8.4.4:53
    timeout: 4s
  tls:
    addr: 1.1.1.1:853
    timeout: 10s
    sni: cloudflare-dns.com
    insecure: false
  https:
    addr: 1.1.1.1:443
    timeout: 10s
    sni: cloudflare-dns.com
    insecure: false
EOL
final
}

Kharej() {
  clear
  first
  read -p "Enter Kharej Ip :" ip
  read -p "Enter the Hy2 port :" port
  read -p "Enter obfs password :" obfspass
  read -p "Enter Authentication pass :" authpass
  read -p "Enter Socks5 port :" sport
  
cat <<EOL > client.yaml
server: "$ip:$port"
auth: "$authpass"
transport:
  type: udp
  udp:
    hopInterval: 30s
obfs:
  type: salamander
  salamander:
    password: "$obfspass"
tls:
  sni: google.com 
  insecure: true 
bandwidth: 
  up: 1 gbps
  down: 1 gbps
quic:
  initStreamReceiveWindow: 8388608 
  maxStreamReceiveWindow: 8388608 
  initConnReceiveWindow: 20971520 
  maxConnReceiveWindow: 20971520 
  maxIdleTimeout: 30s 
  keepAlivePeriod: 10s 
  disablePathMTUDiscovery: false
fastOpen: true
lazy: true
socks5:
  listen: 127.0.0.1:"$sport"
EOL  
  final
}

while true; do
clear
    echo "Menu:"
    echo "1  - Iran"
    echo "2  - Kharej"
    echo "3  - Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) Iran;;
        2) Kharej;;
        3) echo "Exiting..."; exit;;
        *) echo "Invalid choice. Please enter a valid option.";;
    esac
done
