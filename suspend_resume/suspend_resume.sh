#!/bin/bash

RESULT_DIR=/userdata/rockchip-test/
RESULT_LOG=${RESULT_DIR}/suspend_resume.txt
SUSPEND_MIN=60  # Ensure minimum suspend time is 60 seconds
WAKE_MIN=5
MAX_CYCLES=10000

# Enable Debug
# echo N > /sys/module/printk/parameters/console_suspend
# echo 1 > /sys/power/pm_print_times

# Check if RTC is present
if [ ! -e "/sys/class/rtc/rtc0/wakealarm" ]; then
    echo "RTC not present, please check if RTC is enabled"
    exit 1
fi

# Create result directory
mkdir -p ${RESULT_DIR}

# Function to generate random number
random() {
  hexdump -n 2 -e '/2 "%u"' /dev/urandom
}

auto_suspend_resume_rtc() {
    cnt=0

    # Sync system time to RTC
    hwclock --systohc
    echo "$(date): auto_suspend_resume_rtc starts" > ${RESULT_LOG}

    while [ $cnt -lt $MAX_CYCLES ]; do
        echo "Completed $cnt suspend/resume cycles"

        # Calculate suspend time to ensure it's at least 60 seconds
        sus_time=$(( ( $(random) % $SUSPEND_MIN ) + $SUSPEND_MIN ))
        echo "Sleeping for $sus_time seconds"
        # Clear previous wakealarm and set new wake time
        echo 0 > /sys/class/rtc/rtc0/wakealarm
        echo "+${sus_time}" > /sys/class/rtc/rtc0/wakealarm
        pm-suspend

        # Calculate wake time, ensuring at least 30 seconds of wake time
        wake_time=$(( ( $(random) % $WAKE_MIN ) + $WAKE_MIN ))
        echo "Waking for $wake_time seconds"
        sleep $wake_time

        echo "$(date): Cycle: $cnt - Sleep: $sus_time Wake: $wake_time" >> ${RESULT_LOG}

        cnt=$((cnt + 1))
    done
}

auto_suspend_resume_rtc
