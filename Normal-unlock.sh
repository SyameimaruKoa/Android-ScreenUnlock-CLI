#!/system/bin/sh

PIN="$1"

echo "Wake up..."
input keyevent 224
sleep 1

# ロック判定 (Rakuten Mini対応: isStatusBarKeyguard)
IS_LOCKED=$(dumpsys window | grep "isStatusBarKeyguard=true")

if [ -n "$IS_LOCKED" ]; then

    # 引数がなければ入力させる
    if [ -z "$PIN" ]; then
        echo "Enter PIN code:"
        read PIN
    fi

    if [ -z "$PIN" ]; then
        echo "Aborted: No PIN provided."
        exit 1
    fi
    
    settings put system screen_brightness 0
    echo "PASS START..."
    # メニューキーで解除画面呼び出し
    input keyevent 82
    sleep 1

    echo "PASS input..."
    input text "$PIN"
    input keyevent 66 # Enter
    echo "- PASS input OK"
else
    echo "Already Unlocked."
fi

echo "END"
# 正常終了を明示
exit 0