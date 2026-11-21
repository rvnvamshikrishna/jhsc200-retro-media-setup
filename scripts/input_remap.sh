#!/system/bin/sh
# input_remap.sh - Remaps SHANWAN gamepad + USB mouse for Android TV navigation
# Uses Android's built-in 'hid' command to create a virtual keyboard via /dev/uhid
#
# Controller mapping:
#   A button     -> DPAD_CENTER (select)
#   B button     -> BACK
#   Y button     -> HOME  
#   X button     -> MENU
#   START        -> HOME
#   SELECT       -> BACK
#   MODE         -> RECENTS
#   D-pad        -> Arrow keys
#   L1/R1        -> Page Up/Down
#
# Mouse mapping:
#   Right-click  -> BACK
#   Middle-click -> HOME
#
# Usage: sh /data/local/tmp/input_remap.sh &
# Stop:  kill $(cat /data/local/tmp/remap.pid)

PIDFILE="/data/local/tmp/remap.pid"
FIFO="/data/local/tmp/hid_pipe"
GAMEPAD="/dev/input/event7"
MOUSE="/dev/input/event6"

# Kill previous instance
if [ -f "$PIDFILE" ]; then
    kill $(cat "$PIDFILE") 2>/dev/null
    sleep 0.3
fi
echo $$ > "$PIDFILE"

cleanup() {
    rm -f "$FIFO" "$PIDFILE"
    kill 0 2>/dev/null
    exit 0
}
trap cleanup EXIT INT TERM

# Create named pipe
rm -f "$FIFO"
mkfifo "$FIFO" 2>/dev/null

# Keep FIFO open for writing (fd 3) so hid doesn't get EOF
exec 3>"$FIFO"

# Start hid reading from FIFO in background
hid "$FIFO" &
HID_PID=$!
sleep 1

# Register virtual keyboard - standard boot keyboard descriptor
# Max usage extended to 0x73 (115) to cover F-keys and navigation
echo '{"id":1,"command":"register","name":"RemapKB","vid":9999,"pid":9998,"bus":"usb","descriptor":[5,1,9,6,161,1,5,7,25,224,41,231,21,0,37,1,117,1,149,8,129,2,149,1,117,8,129,3,149,5,117,1,5,8,25,1,41,5,145,2,149,1,117,3,145,3,149,6,117,8,21,0,37,115,5,7,25,0,41,115,129,0,192]}' >&3
sleep 1

# Check if hid process is still alive
if ! kill -0 $HID_PID 2>/dev/null; then
    echo "ERROR: hid process died"
    exit 1
fi

echo "Virtual keyboard registered. Monitoring input devices..."

# HID Usage IDs (USB keyboard page 0x07):
# 0x28 (40) = Enter/Return -> maps to KEYCODE_ENTER (works as DPAD_CENTER on Android TV)
# 0x29 (41) = Escape -> maps to KEYCODE_ESCAPE
# 0x4F (79) = Right Arrow
# 0x50 (80) = Left Arrow
# 0x51 (81) = Down Arrow
# 0x52 (82) = Up Arrow
# 0x4B (75) = Page Up
# 0x4E (78) = Page Down
# 0x76 (118)= App/Menu -- actually out of range, use 0x65 (101) = Application

# For BACK and HOME, we use input keyevent since HID keyboard Escape
# may not map to BACK on this Android TV build
send_hid_key() {
    echo "{\"id\":1,\"command\":\"report\",\"report\":[0,0,$1,0,0,0,0,0]}" >&3
    usleep 30000
    echo '{"id":1,"command":"report","report":[0,0,0,0,0,0,0,0]}' >&3
}

# Gamepad button event codes (from getevent -ql):
# 0130 = BTN_SOUTH/BTN_GAMEPAD (A)
# 0131 = BTN_EAST (B)
# 0133 = BTN_NORTH (Y)
# 0134 = BTN_WEST (X)
# 0136 = BTN_TL (L1)
# 0137 = BTN_TR (R1)
# 013a = BTN_SELECT
# 013b = BTN_START
# 013c = BTN_MODE
# ABS 0010 = HAT0X (-1=left, 1=right)
# ABS 0011 = HAT0Y (-1=up, 1=down)

# Mouse button event codes:
# 0110 = BTN_LEFT
# 0111 = BTN_RIGHT
# 0112 = BTN_MIDDLE

process_gamepad() {
    getevent -q "$GAMEPAD" 2>/dev/null | while read type code value; do
        case "$type" in
            0001)  # EV_KEY
                if [ "$value" = "00000001" ]; then  # Key DOWN only
                    case "$code" in
                        0130) send_hid_key 40 ;;  # A -> Enter (DPAD_CENTER)
                        0131) input keyevent 4 & ;;  # B -> BACK
                        0133) input keyevent 3 & ;;  # Y -> HOME
                        0134) send_hid_key 101 ;;  # X -> Application/Menu
                        0136) send_hid_key 75 ;;   # L1 -> Page Up
                        0137) send_hid_key 78 ;;   # R1 -> Page Down
                        013a) input keyevent 4 & ;;  # SELECT -> BACK
                        013b) input keyevent 3 & ;;  # START -> HOME
                        013c) input keyevent 187 & ;; # MODE -> RECENTS
                    esac
                fi
                ;;
            0003)  # EV_ABS
                case "$code" in
                    0010)  # HAT0X (D-pad horizontal)
                        case "$value" in
                            ffffffff) send_hid_key 80 ;;  # Left
                            00000001) send_hid_key 79 ;;  # Right
                        esac
                        ;;
                    0011)  # HAT0Y (D-pad vertical)
                        case "$value" in
                            ffffffff) send_hid_key 82 ;;  # Up
                            00000001) send_hid_key 81 ;;  # Down
                        esac
                        ;;
                esac
                ;;
        esac
    done
}

process_mouse() {
    getevent -q "$MOUSE" 2>/dev/null | while read type code value; do
        if [ "$type" = "0001" ] && [ "$value" = "00000001" ]; then
            case "$code" in
                0111) input keyevent 4 & ;;  # Right-click -> BACK
                0112) input keyevent 3 & ;;  # Middle-click -> HOME
            esac
        fi
    done
}

# Start monitors
process_gamepad &
GP_PID=$!

process_mouse &
MS_PID=$!

echo "Remapper running (PID $$, gamepad=$GP_PID, mouse=$MS_PID)"
echo "  Gamepad: $GAMEPAD -> A=Select B=Back Y=Home X=Menu"
echo "  Mouse:   $MOUSE -> RightClick=Back MiddleClick=Home"

# Wait for children
wait
