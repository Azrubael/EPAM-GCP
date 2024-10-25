#!/bin/bash

# Run the application
java -Djava.security.egd=file:/dev/./urandom -jar /app/spring-petclinic.jar

# Check the app state
CURRENTTIME=$(date +"%Y-%m-%d %H:%M:%S")
if curl - http://localhost:8080/; then
    sudo echo "$CURRENTTIME -- Petclinic is running OK." >> /app/petclinic.log 2>&1 &
    exit 0
else
    sudo echo "$CURRENTTIME -- Petclinic didn't start." >> /app/petclinic.log 2>&1 &
    exit 1
fi