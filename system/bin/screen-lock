#!/system/bin/sh
# Compatibility command for the original Gist.
# Indirectly invoke the same lockctl file even without a system mount.
SCRIPT_DIR="${0%/*}"
if [ "$SCRIPT_DIR" = "$0" ]; then
    SCRIPT_DIR="$(dirname "$(command -v "$0")")"
fi
exec /system/bin/sh "$SCRIPT_DIR/lockctl" lock "$@"
