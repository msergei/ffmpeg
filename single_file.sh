#!/bin/bash

# Проверка наличия аргументов
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: $0 <путь к видеофайлу> <путь к пресету LUT>"
    exit 1
fi

# Параметры
VIDEO_FILE="$1"
LUT_FILE="$2"

# Проверка, существует ли видеофайл
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Видео файл $VIDEO_FILE не найден."
    exit 1
fi

# Проверка, существует ли LUT-файл
if [ ! -f "$LUT_FILE" ]; then
    echo "LUT файл $LUT_FILE не найден."
    exit 1
fi

# Получение пути и имени файла без расширения
OUTPUT_DIR=$(dirname "$VIDEO_FILE")
filename=$(basename "$VIDEO_FILE")
output_file="$OUTPUT_DIR/${filename%.*}_processed.mp4"

# Получение информации о разрешении видео
resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$VIDEO_FILE")
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

# Команда FFmpeg для обработки видео с использованием LUT, аппаратного ускорения и битрейта
ffmpeg -i "$VIDEO_FILE" -vf "${rotate_filter}scale=1080:1920,setsar=1,lut3d=$LUT_FILE" \
       -c:v h264_videotoolbox -b:v 4900k -pix_fmt yuv420p -r 30 -an "$output_file"

echo "Обработка завершена. Готовый файл сохранен: $output_file"
