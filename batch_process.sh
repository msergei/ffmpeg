#!/bin/bash

# Готовим видосы для инстаграма в контейнере

# Директории для ввода и вывода
INPUT_DIR="/tmp/src"
OUTPUT_DIR="/tmp/finish"

# Создаем выходную директорию, если она не существует
mkdir -p "$OUTPUT_DIR"

# Обрабатываем каждый файл в папке src
for file in "$INPUT_DIR"/*.MOV; do
    # Получаем имя файла без пути
    filename=$(basename "$file")

    # Задаем путь к выходному файлу
    output_file="$OUTPUT_DIR/${filename%.*}_enhanced.mp4"

    # Команда FFmpeg с добавлением повышения экспозиции и контраста
    ffmpeg -i "$file" -vf "transpose=1,scale=1080:1920,setsar=1,eq=saturation=3:brightness=0.15:contrast=1.2" -c:v libx264 -crf 18 -level 4.1 -preset veryslow -pix_fmt yuv420p -r 30 -an "$output_file"
done
