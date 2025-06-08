FROM selenium/standalone-chrome:latest

# Variables de entorno para Chrome (valores por defecto)
ENV CHROME_BIN=/usr/bin/google-chrome \
    DISPLAY=:99 \
    NO_SANDBOX=true \
    DISABLE_DEV_SHM_USAGE=true \
    SELENIUM_HEADLESS=true

# Instalación de Python y dependencias
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

USER seluser
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install seleniumbase pymongo[srv] dnspython Flask pyTelegramBotAPI undetected-chromedriver selenium dill

COPY --chown=seluser:seluser . /home/seluser/app
WORKDIR /home/seluser/app

CMD ["python3", "main.py"]