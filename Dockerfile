FROM python
RUN pip install --no-cache-dir --upgrade pip
# need to install a full GUI, apparently
RUN apt update         \
&&  apt install -y     \
      chromium         \
      chromium-driver  \
      chromium-sandbox \
      xvfb             \
      x11vnc \
      fluxbox \
      xterm \
      libffi-dev \
      git \
      ca-certificates \
&& rm -rf /var/lib/apt/lists/*

# install your project
COPY . /home/app
WORKDIR /home/app
RUN pip install --no-cache-dir   
RUN rm -rf /home/app

# not sure if this is necessary
# Create a non-root user
RUN groupadd -r pwuser && useradd -r -g pwuser -G audio,video pwuser \
    && mkdir -p /home/pwuser/Downloads \
    && chown -R pwuser:pwuser /home/pwuser
# Switch to the non-root user
USER pwuser

# run your project
ENTRYPOINT ["python", "-c", "main.py"]