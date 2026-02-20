#!/bin/bash
echo "Hi"

REGION="ap-south-1"

# Get credentials from SSM
DOCKER_USERNAME=$(aws ssm get-parameter \
  --name "/learnbayapp/dockercredentials/username1" \
  --region $REGION \
  --query "Parameter.Value" \
  --output text)

DOCKER_PASSWORD=$(aws ssm get-parameter \
  --name "/learnbayapp/dockercredentials/password1" \
  --with-decryption \
  --region $REGION \
  --query "Parameter.Value" \
  --output text)

# Login to Docker Hub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Pull latest image
docker pull motieno205/python-flask-app:latest

# Stop old container (if exists)
docker stop flask-app || true
docker rm flask-app || true

# Run container
docker run -d -p 5000:5000 --name flask-app motieno205/python-flask-app:latest