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


RUN mkdir -p /home/app
COPY . /home/app
RUN chmod -R 777 /home/app
WORKDIR /home/app

# 3. Instalar paquetes Python
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



EXPOSE 9222

CMD ["python", "main.py"]