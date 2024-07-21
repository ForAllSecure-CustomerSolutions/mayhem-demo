#!/bin/bash
PID=

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

coverage run -m uvicorn app.main:app --host 0.0.0.0 --port 8000 &
PID=$(echo $!)

while true; do
  sleep 1
done