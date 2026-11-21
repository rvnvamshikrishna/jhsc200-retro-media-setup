#!/system/bin/sh
# Remap daemon for SHANWAN Gamepad and USB Mouse

GAMEPAD="/dev/input/event7"
MOUSE="/dev/input/event6"

# Kill old instances
kill $(pgrep -f "getevent.*event[67]") 2>/dev/null

echo "Starting Remap Service..."

# Monitor Gamepad
if [ -e "$GAMEPAD" ]; then
    getevent -q "$GAMEPAD" 2>/dev/null | while read type code value; do
        if [ "$type" = "0001" ] && [ "$value" = "00000001" ]; then
            case "$code" in
                0130) input keyevent 23 & ;; # A button -> DPAD_CENTER (Select)
                0131) input keyevent 4 & ;;  # B button -> BACK
                0133) input keyevent 3 & ;;  # Y button -> HOME
                0134) input keyevent 82 & ;; # X button -> MENU
                013a) input keyevent 4 & ;;  # SELECT -> BACK
                013b) input keyevent 3 & ;;  # START -> HOME
            esac
        elif [ "$type" = "0003" ]; then
            case "$code" in
                0010) # HAT0X (D-Pad Left/Right)
                    case "$value" in
                        ffffffff) input keyevent 21 & ;; # LEFT
                        00000001) input keyevent 22 & ;; # RIGHT
                    esac
                    ;;
                0011) # HAT0Y (D-Pad Up/Down)
                    case "$value" in
                        ffffffff) input keyevent 19 & ;; # UP
                        00000001) input keyevent 20 & ;; # DOWN
                    esac
                    ;;
            esac
        fi
    done &
fi

# Monitor Mouse
if [ -e "$MOUSE" ]; then
    getevent -q "$MOUSE" 2>/dev/null | while read type code value; do
        if [ "$type" = "0001" ] && [ "$value" = "00000001" ]; then
            case "$code" in
                0111) input keyevent 4 & ;; # Right-Click -> BACK
                0112) input keyevent 3 & ;; # Middle-Click -> HOME
            esac
        fi
    done &
fi

