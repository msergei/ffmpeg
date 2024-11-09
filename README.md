# How to start?

- Write your source folder to docker-compose.yml
- Write your result folder to docker-compose.yml
- Check parameters in the batch_process.sh or docker-compose command
- Command: 
``
docker-compose up
``

# Appple arm64 native ffmpeg decode
- Install ffmpeg: brew install ffmpeg
- Start script:

``
chmod +x native_ffmpeg.sh
./native_ffmpeg.sh /Users/USER/FOLDER
``