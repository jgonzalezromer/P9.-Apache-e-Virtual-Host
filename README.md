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
# docker-compose.yml
## DNS

'''

'''

## SW
## Red
### Completo
'''
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
'''

---
# confApache
## fabulasmaravillosas.conf
## fabulasoscuras.conf
---
# confDNS
## Zonas
## conf
### named.conf.local
### named.conf.options
### named.conf
### named.conf.default-zones
---
# www
---
# systemd-resolved.sh
---
# Comprobación
