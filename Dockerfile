FROM selenium/standalone-chrome:latest

# 1. Instalar dependencias como root
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    wget \
    gdebi-core && \
    wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb && \
    sudo apt update
    sudo apt install libu2f-udev
    gdebi --non-interactive /tmp/chrome.deb && \
    rm /tmp/chrome.deb && \
    google-chrome --version && \
    # Limpieza
    apt-get remove -y wget gdebi-core && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

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

USER appuser
WORKDIR /app
COPY --chown=appuser:appuser . .

CMD ["/opt/venv/bin/python", "main.py"]