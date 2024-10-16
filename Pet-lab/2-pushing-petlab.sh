#!/bin/bash
IMAGE='azrubael/petlab:latest'

echo "### [1] -- Building Docker image..."
docker build -t $IMAGE .

echo
echo "### [2] -- Pushing the image 'azrubael/petlab:latest' into docker hub repository"
docker push $IMAGE

echo
echo "### [3] -- Removing local Docker image and cleaning cache..."
docker rmi $IMAGE
docker system prune -f

echo
echo "### [4] -- Pulling Docker image from Docker Hub..."
if docker pull azrubael/petlab:latest; then 
    echo "The image $IMAGE was successfully pulled from DockerHub."
else
    echo "Failed to pull $IMAGE" >&2
fi