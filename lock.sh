#!/system/bin/sh

echo "Locking..."

# 画面状態のチェック
# mWakefulness=Awake があれば変数に何かが入る
STATUS=$(dumpsys power | grep "mWakefulness=Awake")

# 変数が空でなければ（-n）、画面が点いていると判断
if [ -n "$STATUS" ]; then
settings put system screen_brightness 30
    input keyevent 26
    echo "- Screen OFF"
else
    echo "- Already OFF (Skip)"
fi
exit 0