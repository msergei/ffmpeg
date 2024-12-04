#!/bin/bash

# Проверка наличия аргументов
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: $0 <путь к видеофайлу> <путь к папке с LUT-файлами>"
    exit 1
fi

# Параметры
VIDEO_FILE="$1"
LUT_DIR="$2"

# Проверка, существует ли видеофайл
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Видео файл $VIDEO_FILE не найден."
    exit 1
fi

# Проверка, существует ли папка с LUT-файлами
if [ ! -d "$LUT_DIR" ]; then
    echo "Папка с LUT файлами $LUT_DIR не найдена."
    exit 1
fi

# Получение пути и имени видеофайла без расширения
OUTPUT_DIR=$(dirname "$VIDEO_FILE")
filename=$(basename "$VIDEO_FILE")
basename="${filename%.*}"

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

# Обработка каждого LUT-файла в указанной папке
for lut_file in "$LUT_DIR"/*.cube; do
    # Проверка, существует ли LUT файл
    if [[ ! -f "$lut_file" ]]; then
        continue
    fi

    # Извлечение имени LUT файла без расширения
    lut_name=$(basename "$lut_file" .cube)

    # Настройка пути для выходного файла с именем LUT
    output_file="$OUTPUT_DIR/${basename}_${lut_name}_processed.mp4"

    # Команда FFmpeg для обработки видео с использованием LUT, аппаратного ускорения и битрейта
    ffmpeg -i "$VIDEO_FILE" -vf "${rotate_filter}scale=1080:1920,setsar=1,lut3d=$lut_file" \
           -c:v h264_videotoolbox -b:v 4900k -pix_fmt yuv420p -r 30 -an "$output_file"

    echo "Обработан файл с LUT $lut_name. Готовый файл: $output_file"
done

echo "Обработка завершена. Все файлы сохранены в папке: $OUTPUT_DIR"
