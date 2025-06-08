FROM selenium/standalone-chrome:latest

# 1. Configuración base como root
USER root

# 2. Instalar dependencias esenciales
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 3. Crear estructura de directorios
RUN mkdir -p /app/{data,config,downloaded_files} && \
    chown -R seluser:seluser /app

# 4. Instalar dependencias Python
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

# 5. Configurar Chrome y Chromedriver
RUN wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb

# 6. Configuración final
USER seluser
WORKDIR /app
COPY --chown=seluser:seluser . .

ENV DISPLAY=:99 \
    CHROME_BIN=/usr/bin/google-chrome \
    CHROMEDRIVER_PATH=/usr/local/bin/chromedriver \
    NO_SANDBOX=true \
    DISABLE_DEV_SHM=true

CMD ["python3", "main.py"]