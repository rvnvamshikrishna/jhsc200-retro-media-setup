#!/system/bin/sh
echo "=== /dev/uinput access ==="
ls -la /dev/uinput 2>&1
echo "=== sendevent write test ==="
for e in 0 1 2 3 4 5 6 7 8; do
  result=$(sendevent /dev/input/event$e 0 0 0 2>&1)
  if [ -z "$result" ]; then
    echo "event$e: WRITABLE"
  else
    echo "event$e: $result"
  fi
done
echo "=== /dev/uhid ==="
ls -la /dev/uhid 2>&1
echo "=== policy_control ==="
settings put global policy_control "immersive.navigation=*" 2>&1
settings get global policy_control
echo "=== nav bar prop ==="
setprop qemu.hw.mainkeys 0 2>&1
echo "=== overscan ==="
wm overscan 0,0,0,-48 2>&1
echo "=== service list (input/statusbar) ==="
service list | grep -iE 'input|status_bar|window' | head -10
echo "=== Check if we have /dev/uhid write access ==="
cat < /dev/null > /dev/uhid 2>&1 && echo "uhid: WRITABLE" || echo "uhid: NOT writable"

