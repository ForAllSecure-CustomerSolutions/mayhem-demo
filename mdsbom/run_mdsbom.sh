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
if ! mdsbom query --format csv --local containers -a | grep -q $API_IMAGE; then
  echo "ERROR: Image $API_IMAGE has not been recorded."
  exit 1
fi
mdsbom scout --workspace $WORKSPACE --sca-report-out /tmp/dsbom-api.sarif --full-summary $API_IMAGE
