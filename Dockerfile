# Базовый образ с FFmpeg
FROM linuxserver/ffmpeg:latest

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем скрипт для обработки видео
COPY batch_process.sh /app/batch_process.sh

# Делаем скрипт исполняемым
RUN chmod +x /app/batch_process.sh

# Устанавливаем скрипт в качестве точки входа
ENTRYPOINT ["/app/batch_process.sh"]
