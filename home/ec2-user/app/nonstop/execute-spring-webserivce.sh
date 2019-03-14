#!/bin/bash

REPOSITORY=/home/ec2-user/app/nonstop/jar/
APPNAME=spring-webservice
USER=ec2-user
JAVA=/usr/bin/java

#JAR_NAME=$(ls -tr $REPOSITORY/jar |grep $APPNAME a| tail -n 1)

echo '-------------------------------' >> /home/ec2-user/app/nonstop/start.log
date >> /home/ec2-user/app/nonstop/start.log
echo 'Starting spring-webservice' >> /home/ec2-user/app/nonstop/start.log

#sudo su ec2-user
#java -jar $REPOSITORY/jar/$JAR_NAME &

PROFILE1=set1
PROFILE2=set2
JAR_NAME1=set1-spring-webservice.jar
JAR_NAME2=set2-spring-webservice.jar


cd /home/ec2-user/app/nonstop

echo "/bin/su - $USER $JAVA -jar -Dspring.profiles.active=$PROFILE1 $REPOSITORY//$JAR_NAME1 &" >> /home/ec2-user/app/nonstop/start.log
nohup $JAVA -jar -Dspring.profiles.active=$PROFILE1  $REPOSITORY/$JAR_NAME1 &

sleep 20

echo "/bin/su - $USER $JAVA -jar -Dspring.profiles.active=$PROFILE2 $REPOSITORY/$JAR_NAME2 &" >> /home/ec2-user/app/nonstop/start.log
nohup $JAVA -jar -Dspring.profiles.active=$PROFILE2  $REPOSITORY/$JAR_NAME2 &
