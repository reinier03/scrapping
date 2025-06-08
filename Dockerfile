FROM selenium/standalone-chrome:latest

# 1. Instalar dependencias como root
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# 2. Crear entorno virtual con permisos globales
RUN python3 -m venv /opt/venv && \
    chmod -R 777 /opt/venv  # Permisos temporales para instalación

# 3. Instalar paquetes
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install \
    seleniumbase \
    pymongo[srv] \
    dnspython \
    Flask \
    pyTelegramBotAPI \
    undetected-chromedriver \
    selenium \
    dill

# 4. Corregir permisos de SeleniumBase
RUN find /opt/venv -type d -exec chmod 755 {} \; && \
    find /opt/venv -type f -exec chmod 644 {} \; && \
    chmod -R 777 /opt/venv/lib/python3.*/site-packages/seleniumbase/drivers

# 5. Configurar usuario no root
RUN useradd -m appuser && \
    mkdir -p /app/downloaded_files && \
    chown -R appuser:appuser /app


# 6. Habilitar Chrome Remote Debugging
ENV CHROME_DEBUG_PORT=9222
RUN echo 'alias chrome-debug="google-chrome-stable --remote-debugging-port=$CHROME_DEBUG_PORT --user-data-dir=/tmp/chrome-profile --no-sandbox --disable-dev-shm-usage"' >> /etc/bash.bashrc

# 7. Exponer puerto de debugging
EXPOSE $CHROME_DEBUG_PORT

# 8. Configurar Selenium para usar debugging
RUN echo 'export SELENIUM_REMOTE_DEBUG=true' >> /etc/environment && \
    echo 'export SELENIUM_REMOTE_DEBUG_PORT=$CHROME_DEBUG_PORT' >> /etc/environment

USER appuser
WORKDIR /app
COPY --chown=appuser:appuser . .

# 9. Comando con opciones de debugging
CMD ["/opt/venv/bin/python", "main.py"]