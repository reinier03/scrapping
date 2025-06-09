FROM selenium/standalone-chrome:latest

# 1. Instalar dependencias como root
USER root

# Instalar Chrome y dependencias del sistema en un solo RUN para reducir capas
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \

RUN apt -f install -y
RUN apt-get install -y wget
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install ./google-chrome-stable_current_amd64.deb -y

# 2. Crear entorno virtual
RUN python3 -m venv /opt/venv && \
    chmod -R 777 /opt/venv  # Permisos temporales para instalación

# 3. Instalar paquetes Python
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

# 4. Verificar instalación de Chrome en el venv
RUN /opt/venv/bin/python -c "import os; os.system('google-chrome --version')"

# 5. Corregir permisos
RUN find /opt/venv -type d -exec chmod 755 {} \; && \
    find /opt/venv -type f -exec chmod 644 {} \; && \
    chmod -R 777 /opt/venv/lib/python3.*/site-packages/seleniumbase/drivers

# 6. Configurar usuario no root
RUN useradd -m appuser && \
    mkdir -p /app/downloaded_files && \
    chown -R appuser:appuser /app

USER appuser
WORKDIR /app
COPY --chown=appuser:appuser . .

# 7. Verificación final de Chrome
RUN google-chrome --version

CMD ["/opt/venv/bin/python", "main.py"]