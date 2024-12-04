#!/bin/bash

while true; do
    clear
    echo ""
    echo "=== VPS Monitoring Dashboard ==="
    echo "-------------------------------------------------"

    echo "Top 5 CPU Processes:"
    ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -6
    echo ""

    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
    echo ""

    echo "Memory Usage:"
    free -m | grep Mem | awk '{print $3 " MB used / " $2 " MB total"}'
    echo ""

    echo "Disk Usage:"
    df -h | grep '/dev/' | awk '{print $5 " used on " $1}'
    echo ""

    echo "Docker Container Usage:"
    docker stats --no-stream

    sleep 7  # Update interval in seconds
done
