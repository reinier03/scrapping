FROM python:3.10-bullseye

# 1. Instalar dependencias necesarias del sistema y Chrome
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget curl unzip gnupg ca-certificates \
    fonts-liberation libatk-bridge2.0-0 libgtk-3-0 libx11-xcb1 \
    libnss3 libxss1 libasound2 libxcomposite1 libxcursor1 libxdamage1 \
    libxrandr2 libgbm1 libxi6 libgconf-2-4 libappindicator1 libindicator7 \
    xvfb && \
    rm -rf /var/lib/apt/lists/*

# 2. Instalar Google Chrome estable
RUN wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb

# 3. Crear usuario no root
RUN useradd -m appuser
USER appuser
WORKDIR /home/appuser/app

# 4. Copiar archivos y cambiar permisos
COPY --chown=appuser:appuser . .

# 5. Instalar dependencias Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    seleniumbase \
    pymongo \
    dnspython \
    Flask \
    pyTelegramBotAPI \
    undetected-chromedriver \
    selenium \
    dill

# 6. Asegurar carpeta de archivos descargados
RUN mkdir -p /home/appuser/app/downloaded_files

# 7. Ejecutar usando entorno virtual de pantalla
CMD ["xvfb-run", "-a", "python", "main.py"]
