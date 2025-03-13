#!/bin/bash
PID=

# Generate a self-signed certificate on the fly
mkdir -p /app/certs

# Generate an expired certificate (set validity to -1 day)
openssl req -x509 -newkey rsa:4096 \
    -keyout /app/certs/key.pem -out /app/certs/cert.pem \
    -days -1 -nodes -subj "/CN=localhost"

run_coverage_report() {
    echo "Generating coverage xml report..."
    # Stopping uvicorn and letting coverage write the data requires SIGINT here
    kill -SIGINT $PID

    # Wait for the process to die fully
    while [ -d "/proc/$PID" ]; do sleep .1; done

    # Generate xml and move to mount
    coverage xml
    cp coverage.xml /app/coverage

    # Exit cleanly
    exit
}

trap run_coverage_report INT TERM

coverage run -m uvicorn app.main:app \
    --host 0.0.0.0 --port 8443 \
    --ssl-keyfile /app/certs/key.pem \
    --ssl-certfile /app/certs/cert.pem &

PID=$(echo $!)

while true; do
  sleep 1
done
