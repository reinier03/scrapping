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
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Configurar Chrome y Chromedriver
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}') && \
    wget https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION%.*})/chromedriver_linux64.zip -O /tmp/chromedriver.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

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