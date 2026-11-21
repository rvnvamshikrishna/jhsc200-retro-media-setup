#!/system/bin/sh
# Test: Register TWO virtual HID devices
# Device 1: Standard keyboard (for Enter, arrows, Page up/down)
# Device 2: Consumer Control (for Back, Home, Menu)
# Then test sending AC Back via consumer control

FIFO="/data/local/tmp/hid_test_pipe"
rm -f "$FIFO"
mkfifo "$FIFO"
exec 3>"$FIFO"

hid "$FIFO" &
HID_PID=$!
sleep 1

# Device 1: Standard boot keyboard
echo '{"id":1,"command":"register","name":"RemapKB","vid":9999,"pid":9998,"bus":"usb","descriptor":[5,1,9,6,161,1,5,7,25,224,41,231,21,0,37,1,117,1,149,8,129,2,149,1,117,8,129,3,149,5,117,1,5,8,25,1,41,5,145,2,149,1,117,3,145,3,149,6,117,8,21,0,37,115,5,7,25,0,41,115,129,0,192]}' >&3
sleep 0.5

# Device 2: Consumer Control with 16-bit usage
# Descriptor breakdown:
# 05 0C     - Usage Page (Consumer)
# 09 01     - Usage (Consumer Control)
# A1 01     - Collection (Application)
#   15 00   - Logical Minimum (0)
#   26 FF 03 - Logical Maximum (1023)
#   19 00   - Usage Minimum (0)
#   2A FF 03 - Usage Maximum (1023)
#   75 10   - Report Size (16 bits)
#   95 01   - Report Count (1)
#   81 00   - Input (Data, Array, Absolute)
# C0        - End Collection
echo '{"id":2,"command":"register","name":"RemapCC","vid":9999,"pid":9997,"bus":"usb","descriptor":[5,12,9,1,161,1,21,0,38,255,3,25,0,42,255,3,117,16,149,1,129,0,192]}' >&3
sleep 1

echo "Devices registered. Testing AC Back..."

# Open Settings first
am start -n com.android.tv.settings/.MainSettings
sleep 1
echo "Settings opened. Current focus:"
dumpsys window | grep mCurrentFocus

# Send Consumer Control AC Back (Usage 0x0224 = 548 decimal)
# 16-bit little-endian: 0x24, 0x02
echo '{"id":2,"command":"report","report":[36,2]}' >&3
sleep 0.1
echo '{"id":2,"command":"report","report":[0,0]}' >&3
sleep 1

echo "After AC Back:"
dumpsys window | grep mCurrentFocus

# Cleanup
exec 3>&-
kill $HID_PID 2>/dev/null
rm -f "$FIFO"
echo "Test done"

