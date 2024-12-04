#!/bin/bash

# Путь к LUT-файлу
LUT_FILE="/Users/jr/Movies/native.cube"
if [ ! -f "$LUT_FILE" ]; then
    echo "LUT-файл $LUT_FILE не найден."
    exit 1
fi

INPUT_DIR="/Users/jr/Movies/SOURCES/src2"
OUTPUT_DIR="$INPUT_DIR/done"

# Создание папки для сохранения обработанных видео
mkdir -p "$OUTPUT_DIR"

# Обработка каждого видеофайла в указанной папке
for file in "$INPUT_DIR"/*; do
    # Проверка, является ли файл видеофайлом
    if [[ ! -f "$file" ]]; then
        continue
    fi

    # Получение информации о разрешении видео
    resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file")
    width=$(echo $resolution | cut -d'x' -f1)
    height=$(echo $resolution | cut -d'x' -f2)

    # Определение, нужно ли перевернуть видео
    if [ "$width" -gt "$height" ]; then
        # Видео в горизонтальной ориентации — переворачиваем его
        rotate_filter="transpose=1,"
    else
        # Видео в вертикальной ориентации — оставляем как есть
        rotate_filter=""
    fi

    # Настройка пути для выходного файла
    filename=$(basename "$file")
    output_file="$OUTPUT_DIR/${filename%.*}_processed.mp4"

    # Команда FFmpeg для обработки видео с использованием LUT, аппаратного ускорения и битрейта
    # eq=saturation=1.15:brightness=0.15:contrast=1.15
    ffmpeg -i "$file" -vf "${rotate_filter}scale=1080:1920,setsar=1,lut3d=$LUT_FILE" \
           -c:v h264_videotoolbox -b:v 4900k -pix_fmt yuv420p -r 30 -an "$output_file"
done

echo "Обработка завершена. Все файлы сохранены в папке: $OUTPUT_DIR"
