#!/bin/bash
BASE_PATH=/home/ec2-user/app/nonstop
BUILD_PATH=$(ls -tr $BASE_PATH/spring-webservice/build/libs/*.jar | tail -n 1)
JAR_NAME=$(basename $BUILD_PATH)
echo "> build file name: $JAR_NAME"

echo "> Copy build files"
DEPLOY_PATH=$BASE_PATH/jar/
cp $BUILD_PATH $DEPLOY_PATH

echo "> Querying current profile"
CURRENT_PROFILE=$(curl -s http://localhost/profile)
echo "> $CURRENT_PROFILE"

# if current profile is set1 then have to run set2
if [ $CURRENT_PROFILE == set1 ]
then
  IDLE_PROFILE=set2
  IDLE_PORT=8082
elif [ $CURRENT_PROFILE == set2 ]
then
  IDLE_PROFILE=set1
  IDLE_PORT=8081
else
  echo "> Do not exist any Profile."
  echo "> Profile [set1] will be used for web service"
  IDLE_PROFILE=set1
  IDLE_PORT=8081
fi

echo "> Update application.jar "
IDLE_APPLICATION=$IDLE_PROFILE-spring-webservice.jar
IDLE_APPLICATION_PATH=$DEPLOY_PATH$IDLE_APPLICATION

ln -Tfs $DEPLOY_PATH$JAR_NAME $IDLE_APPLICATION_PATH

echo "> Searching the pid of the next Spring-WebService with profile[ $IDLE_PROFILE ]"
IDLE_PID=$(pgrep -f $IDLE_APPLICATION)

if [ -z $IDLE_PID ]
then
  echo "> There are any running Spring-WebService."
else
  echo "> kill -15 $IDLE_PID -- Kill and Redeploy $IDEL_PID"
  kill -15 $IDLE_PID
  sleep 5
fi

echo "> Run java with new Spring-WebService"
echo "> nohup java -jar -Dspring.profiles.active=$IDLE_PROFILE $IDLE_APPLICATION_PATH & "
nohup java -jar -Dspring.profiles.active=$IDLE_PROFILE $IDLE_APPLICATION_PATH &

echo "> After 10 seconds, Start health check for $IDLE_PROFILE"
echo "> curl -s http://localhost:$IDLE_PORT/health "
sleep 10

for retry_count in {1..10}
do
  response=$(curl -s http://localhost:$IDLE_PORT/actuator/health)
  up_count=$(echo $response | grep 'UP' | wc -l)

  # $up_count >= 1 (querying ”UP" string)
  if [ $up_count -ge 1 ]
  then
      echo "> Succeed Health check!!!"
      break
  else
      echo "> There are no response or The status of process is not [UP] status."
      echo "> Health check: ${response}"
  fi

  if [ $retry_count -eq 10 ]
  then
    echo "> Failure health checking $retry_count times."
    echo "> Stop deploying. "
    exit 1
  fi

  echo "> Failure health checking $retry_count. Retrying."
  sleep 5
done

echo "> Switching nginx port"
sleep 5
/home/ec2-user/app/nonstop/switch.sh
