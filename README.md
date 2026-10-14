# Android Lock CLI — Magisk / KernelSU / APatch モジュール

[元のGist](https://gist.github.com/SyameimaruKoa/720cdb0de1597028fbd6334a18e4a8d3) の3つの操作を、systemlessモジュールとしてコマンド化したもの。

- `BFU-unlock.sh`: 数字のキーイベントでPIN入力 (BFU方式)
- `Normal-unlock.sh`: `input text` でPIN入力 (通常方式)
- `lock.sh`: 画面を消灯・ロック
- 新しい統合CLI: `lockctl bfu|normal|lock|status`
- 追加エイリアス: `bfu-unlock`, `normal-unlock`, `screen-lock`

## 対象

- Android 9 (API 28) から Android 16 (API 36) を対象とした互換処理を実装
- Magisk、KernelSU、APatchのモジュールZIPインストールに対応した構成
- **注意:** Android 16実機での動作検証は未実施。PIN画面への入力可否はROM・SystemUI・セキュリティ設定によって異なる。
- KernelSU / APatchの構成によっては `system` フォルダのマウントに対応する**metamodule**が必要。インストール後 `command -v lockctl` が表示されない場合はマウントを確認。

## インストール

1. Magisk / KernelSU / APatchのモジュール画面でZIPを指定してインストールする。
2. デバイスを再起動する。
3. rootシェルで確認する:

```sh
su
command -v lockctl
lockctl status
lockctl --help
```

PATHが通っている場合 `command -v lockctl` は通常 `/system/bin/lockctl` と表示される。

**PATH未反映時**はメタモジュールを有効化し、端末を再起動する。マウントを使わず緊急に実行したい場合は次を使用可能:

```sh
su -c 'sh /data/adb/modules/android_lock_cli/system/bin/lockctl status'
```

### CLIでインストール (Magisk / KernelSU)

モジュールZIPを端末の `/data/local/tmp/Android-Lock-CLI-v1.0.0.zip` に転送してから、導入しているroot管理ソフトに応じて実行する。

```sh
# PC側から転送
adb push Android-Lock-CLI-v1.0.0.zip /data/local/tmp/

# Magiskの場合
adb shell su -c 'magisk --install-module /data/local/tmp/Android-Lock-CLI-v1.0.0.zip'

# KernelSUの場合
adb shell su -c 'ksud module install /data/local/tmp/Android-Lock-CLI-v1.0.0.zip'

# 導入後に再起動
adb reboot
```

APatchはマネージャーのモジュール画面からZIPを導入する。KernelSU / APatchでPATHに現れない場合は、メタモジュールによるsystemマウントが有効か確認する。

### GitHub Actionsによる自動ビルド

`main`へのPushまたは`main`向けPull Requestで、ドキュメント以外のファイルが変更されると、[Build Android Lock CLI module](https://github.com/SyameimaruKoa/Android-ScreenUnlock-CLI/actions/workflows/build-module.yml) が自動実行される。README・Markdown・`docs/` など、ドキュメントのみの変更では自動実行されない。

成功したワークフローの **Artifacts** に `Android-Lock-CLI-<実行番号>` が生成される。これを取得・展開すると、`module.prop` のバージョンに基づく **インストール用モジュールZIP** (`Android-Lock-CLI-v1.0.0.zip` など) とSHA-256チェックサム (`.sha256`) が入っている。Artifactsの保存期間は90日じゃ。

Actions画面の **Run workflow** から手動実行することもできる。なお、このワークフローはGitHub Releaseへの自動公開は行わない。

### GitHubリポジトリからモジュールZIPを作る

リポジトリ直下にある元の3本のスクリプトは履歴と互換性のため残している。モジュールZIPを作るときは、モジュールに必要なファイルだけをZIPのルートに配置する。

```sh
git clone https://github.com/SyameimaruKoa/Android-ScreenUnlock-CLI.git
cd Android-ScreenUnlock-CLI
zip -r Android-Lock-CLI-v1.0.0.zip module.prop customize.sh README.md system
```

`module.prop` はZIPのルートに置くこと。旧スクリプト3本はZIPのルートには含めない。

## 使い方

```sh
# 詳細なヘルプ
lockctl --help
BFU-unlock.sh --help
Normal-unlock.sh --help
lock.sh --help

# 状態確認
lockctl status

# 対話的にPINを入力 (推奨。PINはモジュールに保存しない)
BFU-unlock.sh
Normal-unlock.sh

# 引数にPINを渡す (シェル履歴 / プロセス一覧に露出する可能性あり)
BFU-unlock.sh 1234
Normal-unlock.sh 1234

# 消灯・ロック
lock.sh

# 元の輝度書き換えを使わない
BFU-unlock.sh --no-brightness
lock.sh --no-brightness

# カスタムROMでロック画面が開かない場合はジェスチャーを変更
BFU-unlock.sh --gesture swipe
Normal-unlock.sh --gesture menu
Normal-unlock.sh --gesture dismiss
```

rootシェルでない場合は `su -c 'lockctl status'` のように実行する。

## Android 16対応の変更

1. ロック判定: 旧 `dumpsys window` の `isStatusBarKeyguard` だけでなく、`dumpsys activity activities` の `mKeyguardShowing` などを優先使用。判断不能ならPINを打たずに停止。
2. ロック画面呼び出し: `cmd window dismiss-keyguard` を優先。失敗した場合は BFUモードでスワイプ、Normalモードでメニューキーにフォールバック。
3. スワイプ座標: `wm size` に基づいて画面サイズの20%～80%を計算し、固定座標への依存を削除。
4. PIN入力: BFUモードは数字ごとの `input keyevent` を維持。`Normal` モードは `input text` を維持。
5. 画面消灯: 画面ON/OFFの判定が不明な場合でも、トグル動作のPOWERキーではなく `KEYCODE_SLEEP` (223) を使う。
6. 旧Gistと同様に、デフォルトでロック解除時に輝度0、画面ロック時に輝度30を設定。不要なら `--no-brightness` で無効化。
7. PIN入力は自動再試行しない。送信後5秒間のロック状態を確認して結果を返す。

## 注意・制限

- このモジュールはPINの保存・自動解錠・起動時の自動実行を**しない**。`service.sh` は実装していない。
- `BFU` はデバイスが再起動後最初の認証前であることを指す。Androidの認証やFBEを迂回する機能ではなく、正規のPIN入力を機械操作する。
- OEM独自のPINパッド等ではイベント注入が禁止されることがあり、実機での確認が必要。
- Android 16では、`input text` ではなく `BFU-unlock.sh` (キーイベント方式) が適する場合もある。
- PINを引数に書くと履歴やプロセス一覧に表示され得る。対話入力推奨。
- 画面状態の自動検出ができない機種でも、`lock.sh` は押すたびに消灯する安全なキーイベントを使用する。

## アンインストール

モジュールマネージャーから `Android Lock CLI` を削除し、再起動する。システムパーティションは直接変更していない。

元のGistのスクリプトを別途設置していた場合、同名の古いコマンドがPATHの手前にあるとそちらが優先される。`command -v BFU-unlock.sh` を確認すること。元のスクリプトを消すかどうかは設置場所を確認してから判断する。
