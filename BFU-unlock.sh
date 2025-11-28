#!/system/bin/sh

# 数字をキーコードに変換して押す関数
press_key() {
    case "$1" in
        0) input keyevent 7 ;;
        1) input keyevent 8 ;;
        2) input keyevent 9 ;;
        3) input keyevent 10 ;;
        4) input keyevent 11 ;;
        5) input keyevent 12 ;;
        6) input keyevent 13 ;;
        7) input keyevent 14 ;;
        8) input keyevent 15 ;;
        9) input keyevent 16 ;;
    esac
}

# 1. 引数があるかチェック
PIN="$1"

echo "Start unlocking (Physical Key Mode)..."

# 2. 画面点灯
echo "- Wake up..."
input keyevent 224
sleep 1

# 3. ロック状態を確認
IS_LOCKED=$(dumpsys window | grep "isStatusBarKeyguard=true")

if [ -n "$IS_LOCKED" ]; then
    echo "- Device is LOCKED. Processing..."
    
    # 引数がなければユーザーに入力させる
    if [ -z "$PIN" ]; then
        echo "Enter PIN code:"
        read PIN
    fi

    # PINがそれでも空なら終了
    if [ -z "$PIN" ]; then
        echo "Aborted."
        exit 1
    fi

    # スワイプ
    echo "PASS START..."
    input swipe 360 1000 360 200 500
    echo "- PASS START OK"
    sleep 1

    # 輝度調整
    settings put system screen_brightness 0

    # PINの文字数を取得
    len=${#PIN}
    i=0

    # ループで1文字ずつ処理
    echo "PASS input..."
    while [ $i -lt $len ]; do
        # i番目の文字を取り出す
        char=${PIN:$i:1}

        # キーを押す
        press_key "$char"
        echo "-- PASS input $i"

        # 取りこぼし防止のウェイト (0.1秒)
        sleep 0.1

        i=$((i + 1))
    done

    input keyevent 66 # Enter

    echo "- Waiting for system..."
    sleep 5

else
    echo "- Device is ALREADY UNLOCKED. Skipping."
fi

echo "END"
exit 0