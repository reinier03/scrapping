FROM selenium/standalone-chrome:latest


ENV LANG_WHICH=${LANG_WHICH} \
    LANG_WHERE=${LANG_WHERE} \
    ENCODING=${ENCODING} \
    LANGUAGE=${LANGUAGE} \
    LANG=${LANGUAGE} \
#============================================
# Shared cleanup script environment variables
#============================================
    SE_ENABLE_BROWSER_LEFTOVERS_CLEANUP="false" \
    SE_BROWSER_LEFTOVERS_INTERVAL_SECS="3600" \
    SE_BROWSER_LEFTOVERS_PROCESSES_SECS="7200" \
    SE_BROWSER_LEFTOVERS_TEMPFILES_DAYS="1" \
#========================
# Selenium Configuration
#========================
    SE_EVENT_BUS_PUBLISH_PORT="4442" \
    SE_EVENT_BUS_SUBSCRIBE_PORT="4443" \
    # Drain the Node after N sessions (a value higher than zero enables the feature)
    SE_DRAIN_AFTER_SESSION_COUNT="0" \
    SE_NODE_MAX_SESSIONS="1" \
    SE_NODE_SESSION_TIMEOUT="300" \
    SE_NODE_OVERRIDE_MAX_SESSIONS="false" \
    SE_NODE_HEARTBEAT_PERIOD="30" \
    SE_NODE_REGISTER_PERIOD="120" \
    SE_NODE_REGISTER_CYCLE="10" \
    SE_NODE_REGISTER_SHUTDOWN_ON_FAILURE="true" \
    SE_NODE_CONNECTION_LIMIT_PER_SESSION="10" \
    SE_OTEL_SERVICE_NAME="selenium-node" \
    SE_NODE_RELAY_ONLY="true" \
    # Setting Selenium Manager to work offline
    SE_OFFLINE="true" \
    SE_NODE_BROWSER_VERSION="stable" \
    SE_NODE_PLATFORM_NAME="Linux" \
#============================
# Some configuration options
#============================
    SE_RECORD_VIDEO=false \
    DISPLAY_CONTAINER_NAME="localhost" \
    SE_SCREEN_WIDTH="1920" \
    SE_SCREEN_HEIGHT="1080" \
    SE_SCREEN_DEPTH="24" \
    SE_SCREEN_DPI="96" \
    SE_START_XVFB="true" \
    SE_START_VNC="true" \
    SE_START_NO_VNC="true" \
    SE_NO_VNC_PORT="7900" \
    SE_VNC_PORT="5900" \
    DISPLAY=":99.0" \
    DISPLAY_NUM="99" \
    GENERATE_CONFIG="true" \
    # Following line fixes https://github.com/SeleniumHQ/docker-selenium/issues/87
    DBUS_SESSION_BUS_ADDRESS="/dev/null"




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
    pymongo \
    dnspython \
    Flask \
    pyTelegramBotAPI \
    undetected-chromedriver \
    selenium \
    dill

# 4. Corregir permisos de SeleniumBase
RUN find /opt/venv -type d -exec chmod 755 {} \; && \
    find /opt/venv -type f -exec chmod 644 {} \; && \
    chmod -R 777 /opt/venv/ \
    chmod -R 777 /home/seluser/

# 5. Configurar usuario no root
RUN useradd -m appuser && \
    mkdir -p /app/downloaded_files && \
    chown -R appuser:appuser /app

USER appuser
WORKDIR /app
COPY --chown=appuser:appuser . .

EXPOSE 9222

CMD ["/opt/venv/bin/python", "main.py"]