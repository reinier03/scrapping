FROM selenium/standalone-chrome:latest

# Configuración de variables esenciales
ENV CHROME_BIN=/usr/bin/google-chrome \
    DISPLAY=:99 \
    NO_SANDBOX=true \
    DISABLE_DEV_SHM_USAGE=true \
    SELENIUM_HEADLESS=true \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore

# Configuración del workspace
WORKDIR /app

# Instalación de dependencias del sistema como root
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Crear estructura de directorios con permisos adecuados
RUN mkdir -p downloaded_files f_src && \
    chown -R seluser:seluser /app && \
    chmod -R 755 /app

# Instalación de dependencias Python como seluser
USER seluser
ENV PATH="/home/seluser/.local/bin:${PATH}"

# Solución clave para los permisos:
RUN python3 -m pip install --user --upgrade pip && \
    python3 -m pip install --user \
    seleniumbase \
    pymongo[srv] \
    dnspython \
    Flask \
    pyTelegramBotAPI \
    undetected-chromedriver \
    selenium \
    dill

# Copia de archivos con permisos adecuados
COPY --chown=seluser:seluser . .

CMD ["python3", "main.py"]