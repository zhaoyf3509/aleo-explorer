#!/bin/bash

# simply example
docker build -t aleo-explorer:testnet3 . --progress=plain > build.log 2>&1

docker run -di \
  --name aleo-explorer \
  -p 8000:8000 \
  -p 8001:8001 \
  -e PYTHONUNBUFFERED=1 \
  -e DB_DATABASE=aleo \
  -e DB_HOST=127.0.0.1 \
  -e DB_PASS=abmabm90779 \
  -e DB_SCHEMA=explorer \
  -e DB_USER=postgres \
  -e P2P_NODE_HOST=127.0.0.1 \
  -e P2P_NODE_PORT=4130 \
  -e DEBUG=1 \
  -e BLOCK_GENESIS=/mnt/block.genesis \
  -v /home/abm/huang/aleo-explorer/node/testnet3/block.genesis:/mnt/block.genesis \
  aleo-explorer:testnet3

