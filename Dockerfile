FROM ubuntu:22.04

# set metadata for the image
LABEL maintainer="aleo-explorer"
LABEL version="testnet3"
LABEL description="This is a custom image for Aleo Explorer"

EXPOSE 8000
EXPOSE 8001

# install deps
USER root
RUN apt --fix-broken install && \
    apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install --no-install-recommends -y python3-pip git curl pkg-config libssl-dev build-essential&& \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install Rust and Aleo Explorer Rust
USER root
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    pip install --use-pep517 setuptools_rust && \
    git clone https://github.com/HarukaMa/aleo-explorer-rust.git && \
    cd aleo-explorer-rust && \
    pip install .

# install Aleo Explorer Python
USER root
RUN git clone -b testnet3-hxc https://github.com/hxuchen/aleo-explorer.git && \
    cd aleo-explorer && \
    pip3 install --no-cache-dir -r requirements.txt

## set env
#ENV PYTHONUNBUFFERED=1 \
#    DB_DATABASE=aleo \
#    DB_HOST=localhost \
#    DB_PASS=mysecretpassword \
#    DB_SCHEMA=explorer \
#    DB_USER=postgres \
#    P2P_NODE_HOST=127.0.0.1 \
#    P2P_NODE_PORT=4130 \
#    DEBUG=1

# run
USER root
CMD cd /aleo-explorer && python3 main.py