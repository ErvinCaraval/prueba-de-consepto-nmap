FROM ubuntu:20.04

LABEL maintainer="VulnApp Demo"
LABEL description="Máquina vulnerable para reconocimiento masivo con Masscan"

ENV DEBIAN_FRONTEND=noninteractive

# Instalar curl, Redis, Memcached y Supervisor
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        redis-server \
        memcached \
        supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Configuración Redis ──
# Dejar Redis escuchando en todas las interfaces y sin proteger
RUN sed -i 's/bind 127.0.0.1 ::1/bind 0.0.0.0/' /etc/redis/redis.conf
RUN sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf

# ── Configuración Memcached ──
# Escuchando en todos lados
RUN sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf

# ── Configuración Aplicación Web Node.js (Puerto 80) ──
WORKDIR /app
COPY app/package.json ./
RUN npm install
COPY app/ .

# ── Supervisor ──
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponemos 6379 (Redis), 11211 (Memcached) y 80 (App)
EXPOSE 6379 11211 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
