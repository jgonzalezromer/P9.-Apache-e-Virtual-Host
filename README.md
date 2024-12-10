<h1>
<p align=center>
P9. Apache e Virtual Host
</p>
</h1>
<h3>
<p align=center>
Juan Gabriel González Romero
</p>
</h3>

---
# Obxetivo
O obxetivo de esta práctica é engadir a un docker-compose onde xa hai un DNS funcional un servidor web (apache). O DNS terá que resolver dous dominios.

---
# docker-compose.yml
O docker-compose que utilizamos terá dous servizos(DNS e WEB) e unha rede (apache_red).
## DNS
O DNS será bastante simple:
```
dns:
    container_name: dns_server #Nome do container
    image: ubuntu/bind9 #Imaxe do DNS
    ports:
      - "57:53" #Portos mapeados, máquina:container
    volumes:
      - ./confDNS/conf:/etc/bind #A configuración do DNS irá no directorio confDNS/conf (/etc/bin no container)
      - ./confDNS/zonas:/var/lib/bind #A información das zonas do DNS irá no directorio condDNS/zonas (/var/lib/bind no container)
    networks:
      apache_red: #O container utilizará a rede apache_red
        ipv4_address: 172.39.4.3 #Terá a IP fixa 172.39.4.3
```
## WEB
Para o servidor web utilizamos apache:
```
web:
    image: php:7.4-apache #Imaxe de apache que utilizamos
    container_name: apache_server #Nome do container
    ports:
      - "80:80" #Mapearemos o porto 80 da máquina para o container (poderíamos utilizar o 8080 tamén)
    volumes:
      - ./www:/var/www #A información das paxinas web (os arquivos .html) estará no directorio www (/var/www no container)
      - ./confApache:/etc/apache2 #A configuración de apache irá no directorio confApache (/etc/apache2 no container)
    networks:
      apache_red: #O servidor apache utilizará a rede apache_red
        ipv4_address: 172.39.4.2 #Terá a IP fixa 182.39.4.2
```
## Red
Agorá creamos a rede na cal estarán os containers:
```
networks:
  apache_red: #Nome da rede
    driver: bridge #Tipo da rede
    ipam:
      driver: default
      config:
        - subnet: 172.39.0.0/16 #Subnet onde se atopará
```
### Completo
```
services:
  web:
    image: php:7.4-apache
    container_name: apache_server
    ports:
      - "80:80"
    volumes:
      - ./www:/var/www
      - ./confApache:/etc/apache2
    networks:
      apache_red:
        ipv4_address: 172.39.4.2

  dns:
    container_name: dns_server
    image: ubuntu/bind9
    ports:
      - "57:53"
    volumes:
      - ./confDNS/conf:/etc/bind
      - ./confDNS/zonas:/var/lib/bind
    networks:
      apache_red:
        ipv4_address: 172.39.4.3

networks:
  apache_red:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.39.0.0/16
```

---
# confApache
Neste directorio gardaremos a configuración de apache.
## fabulasmaravillosas.conf
Neste documento tipo xml gardaremos a información que terá apache sobre as nosas páxinas:
```
<VirtualHost *:80> #O virtual host escoitará calquers IP polo porto 80
    ServerAdmin webmaster@localhost #Indicamos o correo do administrador
    ServerName fabulasmaravillosas.asircastelao.int #Nome principal do server
    ServerAlias www.fabulasmaravillosas.asircastelao.int #Outros nome polos que se pode identifacar o servidor
    DocumentRoot /var/www/fabulasmaravillosas #Directorio onde estará a información da páxina
</VirtualHost>
```
## fabulasoscuras.conf
```
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName fabulasoscuras.asircastelao.int
    ServerAlias www.fabulasoscuras.asircastelao.int
    DocumentRoot /var/www/fabulasoscuras
</VirtualHost>
```
---
# confDNS
## Zonas
```
$TTL    604800
@       IN      SOA     ns.asircastelao.int. some.email.address.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@       IN      NS      ns.asircastelao.int.
ns 	IN 	A 	172.39.4.3
fabulasoscuras       IN      A       172.39.4.2
fabulasmaravillosas     IN      A       172.39.4.2
```
## conf
### named.conf.local
```
zone "asircastelao.int" {
    type master;
    file "/var/lib/bind/db.asircastelao.int";
    allow-query {
    	any;
    	};
};
```
### named.conf.options
```
options {
    directory "/var/cache/bind";
    recursion yes;                      # Permitir la resolución recursiva
    allow-query { any; };               # Permitir consultas desde cualquier IP
    dnssec-validation no;
    forwarders {
        8.8.8.8;                        # Google DNS
        1.1.1.1;                        # Cloudflare DNS
    };
    listen-on { any; };                 # Escuchar en todas las interfaces
    listen-on-v6 { any; };
};
```
### named.conf
```
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
```
### named.conf.default-zones
```
// prime the server with knowledge of the root servers
zone "." {
	type hint;
	file "/usr/share/dns/root.hints";
};

// be authoritative for the localhost forward and reverse zones, and for
// broadcast zones as per RFC 1912

zone "localhost" {
	type master;
	file "/etc/bind/db.local";
};

zone "127.in-addr.arpa" {
	type master;
	file "/etc/bind/db.127";
};

zone "0.in-addr.arpa" {
	type master;
	file "/etc/bind/db.0";
};

zone "255.in-addr.arpa" {
	type master;
	file "/etc/bind/db.255";
};
```
---
# www
Nesta carpeta é onde gardamos os documentos .html que utilizaran has páxinas ao cargarse.
---
# systemd-resolved.sh
sudo chmod 755 ./systemd-resolved.sh
```
#/bin/bash
echo "#Documento onde indicamos o DNS
[Resolve]
DNS=172.39.4.3" | sudo tee /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

PROFILE_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":" | awk -F':' '{print $1}')

if [ -z "$PROFILE_NAME" ]; then
    echo "No se detectó ninguna conexión activa. Verifica tu conexión de red."
    exit 1
fi
nmcli connection modify "$PROFILE_NAME" ipv4.ignore-auto-dns yes
nmcli connection down "$PROFILE_NAME" && nmcli connection up "$PROFILE_NAME"
```
# restore_systemd-resolved.sh
sudo chmod 755 ./restore_systemd-resolved.sh
```
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

PROFILE_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":" | awk -F':' '{print $1}')
nmcli connection modify "$PROFILE_NAME" ipv4.ignore-auto-dns no
nmcli connection down "$PROFILE_NAME" && nmcli connection up "$PROFILE_NAME"
```


---
# Comprobación
