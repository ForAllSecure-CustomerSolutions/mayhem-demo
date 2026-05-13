#!/bin/ash

cp /mdsbom/config.toml /etc/mdsbom/config.toml

echo "[sync]" >> /etc/mdsbom/config.toml
echo "upstream_url = \"$MAYHEM_URL\"" >> /etc/mdsbom/config.toml
echo "api_token = \"$MAYHEM_TOKEN\"" >> /etc/mdsbom/config.toml
echo "workspace = \"$WORKSPACE\"" >> /etc/mdsbom/config.toml

mdsbom login $MAYHEM_URL $MAYHEM_TOKEN
mdsbom server > /var/log/mdsbom-server.log &
sleep 5
docker pull $API_IMAGE
docker run --runtime=mdsbom $API_IMAGE &
PID=$!
sleep 5
kill -INT $PID
if mdsbom query --format csv containers -a | grep -q $API_IMAGE; then
  mdsbom scout --sca-report-out /tmp/dsbom-api.sarif --full-summary $API_IMAGE
else
  echo "WARN: Image $API_IMAGE has not been recorded on server; attempting local scan instead"
  if ! mdsbom query --local --format csv containers -a | grep -q $API_IMAGE; then
    echo "ERROR: Image $API_IMAGE has not been recorded locally either; exiting..."
    exit 1
  fi
  mdsbom scout --local --sca-report-out /tmp/dsbom-api.sarif --full-summary $API_IMAGE
fi