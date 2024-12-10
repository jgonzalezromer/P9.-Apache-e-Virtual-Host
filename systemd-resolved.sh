#/bin/bash
# Configurar el archivo de resolución con un DNS específico
echo "# Documento onde indicamos o DNS
[Resolve]
DNS=172.39.4.3" | sudo tee /etc/systemd/resolved.conf

# Reiniciar el servicio de resolución de DNS
sudo systemctl restart systemd-resolved

# Detectar la conexión activa (filtrar solo Ethernet o conexiones relevantes)
PROFILE_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | grep -E "ethernet|wifi" | head -n 1 | cut -d: -f1)

# Verificar si se detectó una conexión activa
if [ -z "$PROFILE_NAME" ]; then
    echo "No se detectó ninguna conexión activa relevante. Verifica tu conexión de red o hazlo de forma manual."
    exit 1
fi

# Configurar la conexión para ignorar el DNS automático
nmcli connection modify "$PROFILE_NAME" ipv4.ignore-auto-dns yes

# Reiniciar la conexión
nmcli connection down "$PROFILE_NAME" && nmcli connection up "$PROFILE_NAME"

echo "Configuración de DNS aplicada con éxito a la conexión: $PROFILE_NAME"
