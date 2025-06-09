FROM selenium/standalone-chrome:latest

# 1. Instalar dependencias como root
USER root

# Instalar Chrome y dependencias del sistema en un solo RUN para reducir capas
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \

RUN apt-get install -y wget
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \ 
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get -y install google-chrome-stable


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