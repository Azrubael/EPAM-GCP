#!/bin/bash

# List of Docker images to pull
images=(
    "hlebsur/mysql:8"
    "hlebsur/pet_clinic_not_full:latest"
    "eclipse-temurin:18-jre-jammy"
)

# Pull each image and check for success
for image in "${images[@]}"; do
    if docker pull "$image"; then
        echo "Successfully pulled $image"
    else
        echo "Failed to pull $image" >&2
    fi
done

# Check if all images were pulled successfully
if [ $? -eq 0 ]; then
    echo "All images pulled successfully."
else
    echo "Some images failed to pull."
fi
