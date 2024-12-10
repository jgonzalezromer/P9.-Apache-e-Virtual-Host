#/bin/bash
echo "# Archivo de configuración predeterminado
[Resolve]
#DNS=
#FallbackDNS=
#Domains=
#LLMNR=yes
#MulticastDNS=yes
#DNSSEC=no
#DNSOverTLS=no
#Cache=yes
#DNSStubListener=yes" | sudo tee /etc/systemd/resolved.conf

sudo systemctl restart systemd-resolved

PROFILE_NAME=$(nmcli -t -f NAME connection show --active | grep "Conexión cableada" | head -n 1)

if [ -z "$PROFILE_NAME" ]; then
    echo "No se encontró una conexión activa válida. Intentalo de forma manual."
    exit 1
fi

nmcli connection modify "$PROFILE_NAME" ipv4.ignore-auto-dns no
nmcli connection down "$PROFILE_NAME" && nmcli connection up "$PROFILE_NAME"
