#  NeonCorp — Entorno Vulnerable para Prácticas con Nmap

Bienvenido a tu entorno de práctica de Nmap. Este repositorio contiene un contenedor Docker intencionalmente vulnerable diseñado para mejorar tus habilidades de reconocimiento en la **Fase 1 del Cyber Kill Chain**.

##  1. Levantar el Entorno (Target)

Primero, simulemos la máquina de la víctima (NeonCorp). Ejecuta este comando en la raíz del proyecto para levantar el contenedor vulnerable:

```bash
docker compose up --build -d
```

>  **IMPORTANTE:** Este contenedor es intencionalmente inseguro. Ejecútalo únicamente en tu red local (localhost) para fines educativos.

---

##  2. Tutorial: Escaneo y Reconocimiento con NMAP

Ahora, asume el rol del atacante. Vamos a usar **Nmap** para descubrir los vectores de ataque en la máquina corporativa que acabamos de levantar.

El objetivo está en tu propia máquina, así que el *target* será `localhost` o `127.0.0.1`.

### Paso 2.1: Descubrimiento Básico de Puertos
Lo primero que hace un atacante es saber qué puertas están abiertas.

```bash
nmap localhost
```
 **¿Qué ves?** Deberías ver los puertos `21` (ftp), `22` (ssh), `23` (telnet) y `80` (http) abiertos.

### Paso 2.2: Escaneo Profundo (Versiones y SO)
Saber que el puerto 21 está abierto no basta. Necesitamos saber *qué programa exactamente* está corriendo ahí. Le decimos a nmap que detecte versiones (`-sV`) y use scripts básicos (`-sC`).

```bash
nmap -sV -sC localhost
```
 **Analiza la salida:**
- **Puerto 80 (HTTP):** Identificarás que es un servidor Node.js/Express (Ubuntu). Si lees los headers expuestos (o visitas `http://localhost` en tu navegador), verás que es el Panel Corporativo de "NeonCorp". También notarás comentarios HTML de los desarrolladores filtrando información.
- **Puerto 22 (SSH):** Verás la versión exacta de OpenSSH.
- **Puerto 23 (Telnet):** Notarás que este protocolo obsoleto, sin cifrar, está activo.
- **Puerto 21 (FTP):** ** ¡VULNERABILIDAD CRÍTICA! ** Verás el mensaje: `Anonymous FTP login allowed`.

### Paso 2.3: Explotando la Vulnerabilidad FTP (Vía Nmap Scripts - NSE)

Nmap no solo mapea, también tiene el *Nmap Scripting Engine (NSE)* que permite automatizar chequeos de seguridad. Ya descubrimos que el FTP permite inicio de sesión "Anonymous" (es decir, entrar sin usuario ni contraseña válida).

Vamos a ver si hay archivos dentro usando el script `ftp-anon`:

```bash
nmap -p 21 --script ftp-anon localhost
```
 **¿Qué encontraste?** Nmap te listará el contenido del servidor FTP. Deberías ver un directorio `/pub` con un archivo sospechoso llamado `database_credentials.txt`.

### Paso 2.4: Comprobación de la Filtración de Datos

Como atacante real, probarías conectarte al servidor FTP ahora que conoces la falla:

```bash
# Conéctate al FTP (Si te pide Name, escribe: anonymous. El password déjalo en blanco)
ftp localhost

# Dentro del FTP, navega y descarga el archivo:
ftp> cd pub
ftp> get database_credentials.txt
ftp> exit

# Revisa tu botín:
cat database_credentials.txt
```

¡Felicidades! Has completado la fase de reconocimiento, has encontrado credenciales filtradas y podrías avanzar a la fase de *Explotación* en la Cyber Kill Chain.

---

## Limpieza del Entorno

Cuando termines tu práctica, puedes destruir la máquina de la víctima:

```bash
docker compose down
```
