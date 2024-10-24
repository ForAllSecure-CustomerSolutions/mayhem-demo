#!/usr/bin/env bash
set -euxo pipefail

host="$1"
shift
cmd="$@"

max_attempts=15
attempt_num=1

until nc -z "$host" 8000; do
  if [ $attempt_num -eq $max_attempts ]; then
    echo "Reached maximum attempts, $host:8000 is still not up"
    exit 1
  fi

  echo "Waiting for $host:8000... (Attempt: $attempt_num)"
  attempt_num=$((attempt_num + 1))
  sleep 1
done

echo "$host:8000 is up - executing command"
exec $cmd

