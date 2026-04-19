#!/bin/bash

#!/bin/bash

# هندور على الفولدر اللي جواه ملف اسمه name ومحتواه k10temp
for dir in /sys/class/hwmon/hwmon*; do
    if [ "$(< "$dir/name")" = "k10temp" ]; then
        HWMON_DIR="$dir"
        break
    fi
done

# لو ما لقاش المسار يخرج عشان ما يطلعش error في الـ bar
if [ -z "$HWMON_DIR" ]; then exit 1; fi

# قراءة الحرارة (غالباً tctl أو temp1 هي الأدق في Ryzen)
TEMP=$(cat "$HWMON_DIR/temp1_input" 2>/dev/null)
CELSIUS=$((TEMP / 1000))

echo "${CELSIUS}°C"

# تحديد اللون
if [ "$CELSIUS" -le 55 ]; then
    echo "#00FF00"
elif [ "$CELSIUS" -le 80 ]; then
    echo "#FFFF00"
else
    echo "#FF0000"
fi
