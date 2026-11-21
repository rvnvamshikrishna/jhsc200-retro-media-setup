#!/system/bin/sh
# Test if hid actually creates a device and sends recognizable events

# Clean up first
am force-stop com.android.tv.settings
input keyevent 3
sleep 0.5

echo "=== Starting hid with pipe ==="

{
  # Register keyboard
  echo '{"id":1,"command":"register","name":"TestKB","vid":9999,"pid":9998,"bus":"usb","descriptor":[5,1,9,6,161,1,5,7,25,224,41,231,21,0,37,1,117,1,149,8,129,2,149,1,117,8,129,3,149,5,117,1,5,8,25,1,41,5,145,2,149,1,117,3,145,3,149,6,117,8,21,0,37,115,5,7,25,0,41,115,129,0,192]}'
  sleep 2
  
  echo "=== Checking for new input device ===" >&2
  ls -la /dev/input/ >&2
  getevent -pl 2>&1 | grep -A2 'TestKB\|9999' >&2
  dumpsys input | grep -A5 'TestKB\|9999' >&2
  
  # Try sending Enter (0x28 = 40)
  echo "=== Sending Enter key ===" >&2
  echo '{"id":1,"command":"report","report":[0,0,40,0,0,0,0,0]}'
  sleep 0.1
  echo '{"id":1,"command":"report","report":[0,0,0,0,0,0,0,0]}'
  sleep 1
  
  # Try sending Down arrow (0x51 = 81)
  echo "=== Sending Down arrow ===" >&2
  echo '{"id":1,"command":"report","report":[0,0,81,0,0,0,0,0]}'
  sleep 0.1
  echo '{"id":1,"command":"report","report":[0,0,0,0,0,0,0,0]}'
  sleep 1
  
  echo "=== Done ===" >&2
} | hid - 2>&1

echo "=== hid exited ==="

