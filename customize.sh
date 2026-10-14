#!/system/bin/sh
# Install-time permissions. This script is called by Magisk / KernelSU / APatch.
ui_print '- Installing Android Lock CLI'
ui_print '- Commands are mounted under /system/bin'
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
