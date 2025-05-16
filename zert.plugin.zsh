#!/usr/bin/env zsh
fpath=("$ZERT_PLUGINS_DIR/zert/functions" $fpath)
autoload -Uz zert-load zert-update zert-clean zert-use zert-fetch zert-log zert-id