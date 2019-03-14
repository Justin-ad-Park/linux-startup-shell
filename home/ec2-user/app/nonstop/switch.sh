#!/bin/bash
echo "> Query running port "
CURRENT_PROFILE=$(curl -s http://localhost/profile)

#
if [ $CURRENT_PROFILE == set1 ]
then
  IDLE_PORT=8082
elif [ $CURRENT_PROFILE == set2 ]
then
  IDLE_PORT=8081
else
  echo "> Doesn’t exist running port."
  IDLE_PORT=8081
fi

echo "> Selected Port: $IDLE_PORT"
echo "> Changing Port "
echo "set \$service_url http://127.0.0.1:${IDLE_PORT};" |sudo tee /etc/nginx/conf.d/service-url.inc

PROXY_PORT=$(curl -s http://localhost/profile)
echo "> Nginx Current Proxy Port: $PROXY_PORT"

echo "> Nginx Reload"
sudo service nginx reload
