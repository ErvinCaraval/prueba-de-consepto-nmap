FROM ubuntu:20.04

LABEL maintainer="VulnApp Demo"
LABEL description="Máquina vulnerable para reconocimiento con Nmap - Cyber Kill Chain"

ENV DEBIAN_FRONTEND=noninteractive

# Instalar Node.js, VSFTPD, Telnet, OpenSSH y Supervisor
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        vsftpd \
        openbsd-inetd \
        telnetd \
        openssh-server \
        supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Configuración SSH ──
RUN mkdir /var/run/sshd
RUN echo 'root:cyberpunk2077' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# ── Configuración Telnet ──
# Telnet escucha en el puerto 23 por defecto a través de inetd
RUN echo "telnet stream tcp nowait root /usr/sbin/tcpd /usr/sbin/in.telnetd" >> /etc/inetd.conf

# ── Configuración FTP (vsftpd) ──
# Permitir acceso anónimo y mensajes de banner ruidosos
RUN mkdir -p /var/run/vsftpd/empty
RUN mkdir -p /var/ftp/pub
RUN echo "anon_world_readable_only=YES" >> /etc/vsftpd.conf
RUN echo "anonymous_enable=YES" >> /etc/vsftpd.conf
RUN echo "no_anon_password=YES" >> /etc/vsftpd.conf
RUN echo "hide_ids=YES" >> /etc/vsftpd.conf
RUN echo "ftpd_banner=Welcome to NeonCorp Internal FTP Service - CONFIDENTIAL." >> /etc/vsftpd.conf
RUN echo "anon_root=/var/ftp" >> /etc/vsftpd.conf
RUN echo "pasv_enable=YES" >> /etc/vsftpd.conf
RUN echo "pasv_min_port=21100" >> /etc/vsftpd.conf
RUN echo "pasv_max_port=21110" >> /etc/vsftpd.conf
RUN echo "pasv_address=127.0.0.1" >> /etc/vsftpd.conf
# Archivo sensible "filtrado" por FTP
RUN echo "NEON_CORP_DB_CREDS=admin:Th1s1sS3cr3t123!" > /var/ftp/pub/database_credentials.txt
RUN chmod 755 /var/ftp && chmod 755 /var/ftp/pub && chmod 644 /var/ftp/pub/database_credentials.txt

# ── Configuración Aplicación Web Node.js (Puerto 80) ──
WORKDIR /app
COPY app/package.json ./
RUN npm install
COPY app/ .

# ── Supervisor: Para correr los 4 servicios (SSH, FTP, Telnet, App) ──
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponemos puertos:
# 21 (FTP), 22 (SSH), 23 (Telnet), 80 (HTTP), y 21100-21110 para FTP pasivo
EXPOSE 21 22 23 80 21100-21110

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
