#!/bin/bash
# Intention is to run this with the test.py from a fresh ubuntu host

docker compose pull --ignore-buildable -q
docker compose build

docker compose up -d --wait && docker ps

while ! curl -s http://localhost:8000/openapi.json; do sleep 1; done

mapi run "mharmon/acceptance-criteria/api" 0 http://localhost:8000/openapi.json \
    --url http://localhost:8000 --interactive 

mayhem run

docker compose down

sleep 15 && mdsbom query --workspace <> containers -a

mdsbom anchore 
mdsbom anchore