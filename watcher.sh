#!/bin/bash
APP_NAME="arithmetic-api"
IMAGE_NAME="arithmetic-api"
PORT=5000

echo "[INFO] Starting watcher for $APP_NAME..."

# Function to build and deploy
build_and_run() {
    echo "[INFO] Change detected. Rebuilding Docker image..."
    docker build -t $IMAGE_NAME .
    
    # Stop and remove existing container if running
    if [ "$(docker ps -q -f name=$APP_NAME)" ]; then
        docker stop $APP_NAME && docker rm $APP_NAME
    fi

    echo "[INFO] Starting new container..."
    docker run -d -p $PORT:5000 --name $APP_NAME $IMAGE_NAME
}

# Initial build
build_and_run

# Monitor for changes
inotifywait -m -e modify,create,delete ./ |
while read path action file; do
    echo "[INFO] Detected change in $file"
    build_and_run
done
