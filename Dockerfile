# Imagen base ligera con Chrome y herramientas necesarias
FROM python:3.10-slim

# 1. Instalar dependencias del sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget unzip gnupg ca-certificates \
    curl xvfb libxi6 libgconf-2-4 libnss3 libxss1 libappindicator1 libindicator7 \
    fonts-liberation libatk-bridge2.0-0 libgtk-3-0 libx11-xcb1 libdbus-glib-1-2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Instalar Chrome estable
RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable

# 3. Crear usuario appuser
RUN useradd -m appuser
USER appuser
WORKDIR /home/appuser/app

# 4. Copiar código
COPY --chown=appuser:appuser . .

# 5. Instalar dependencias de Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    seleniumbase \
    pymongo[srv] \
    dnspython \
    Flask \
    pyTelegramBotAPI \
    undetected-chromedriver \
    selenium \
    dill

# 6. Crear carpeta para archivos temporales
RUN mkdir -p /home/appuser/app/downloaded_files

# 7. Comando de ejecución
CMD ["xvfb-run", "-a", "python", "main.py"]
