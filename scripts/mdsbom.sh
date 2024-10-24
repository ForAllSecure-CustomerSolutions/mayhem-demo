#!/bin/ash

docker login
dockerd &
docker run ghcr.io/forallsecure-customersolutions/mayhem-demo/api:latest &
PID=$!
sleep 5
kill -INT $PID
mdsbom scout ghcr.io/forallsecure-customersolutions/mayhem-demo/api:latest --sca-report-out /tmp/dsbom-api.sarif --full-summary