#!/usr/bin/env zsh
# Tests for lib/__zert-log
set -e

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

TEMP_OUT=$(mktemp)
TEMP_ERR=$(mktemp)

# Helper to reset environment
function reset_env {
    unset ZERT_ICON_STYLE
    zstyle -d ':zert:log' icon-style
}

function test_zert_log_debug_outputs_gray_bold_to_stderr_with_nerd_icon {
    reset_env
    ZERT_ICON_STYLE="nerd"
    source "$HERE/../lib/__zert-log"
    __zert-log debug "Debug message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;38;5;8m[ZERT]: \uf188 Debug message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_debug_outputs_gray_bold_to_stderr_with_nerd_icon

function test_zert_log_info_outputs_blue_bold_to_stderr_with_nerd_icon {
    reset_env
    ZERT_ICON_STYLE="nerd"
    source "$HERE/../lib/__zert-log"
    __zert-log info "Info message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;34m[ZERT]: \uf05a Info message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_info_outputs_blue_bold_to_stderr_with_nerd_icon

function test_zert_log_warning_outputs_yellow_bold_to_stderr_with_nerd_icon {
    reset_env
    ZERT_ICON_STYLE="nerd"
    source "$HERE/../lib/__zert-log"
    __zert-log warning "Warning message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;33m[ZERT]: \uf071 Warning message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_warning_outputs_yellow_bold_to_stderr_with_nerd_icon

function test_zert_log_error_outputs_red_bold_to_stderr_with_nerd_icon_and_error_code {
    reset_env
    ZERT_ICON_STYLE="nerd"
    source "$HERE/../lib/__zert-log"
    __zert-log error 1 "Error message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;31m[ZERT]: \uf057 Error message (1)\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_error_outputs_red_bold_to_stderr_with_nerd_icon_and_error_code

function test_zert_log_debug_outputs_emoji_when_icon_style_is_emoji {
    reset_env
    ZERT_ICON_STYLE="emoji"
    source "$HERE/../lib/__zert-log"
    __zert-log debug "Debug message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;38;5;8m[ZERT]: 🐛 Debug message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_debug_outputs_emoji_when_icon_style_is_emoji

function test_zert_log_info_outputs_emoji_when_icon_style_is_emoji {
    reset_env
    ZERT_ICON_STYLE="emoji"
    source "$HERE/../lib/__zert-log"
    __zert-log info "Info message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;34m[ZERT]: ℹ️ Info message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_info_outputs_emoji_when_icon_style_is_emoji

function test_zert_log_warning_outputs_emoji_when_icon_style_is_emoji {
    reset_env
    ZERT_ICON_STYLE="emoji"
    source "$HERE/../lib/__zert-log"
    __zert-log warning "Warning message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;33m[ZERT]: ⚠️ Warning message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_warning_outputs_emoji_when_icon_style_is_emoji

function test_zert_log_error_outputs_emoji_when_icon_style_is_emoji {
    reset_env
    ZERT_ICON_STYLE="emoji"
    source "$HERE/../lib/__zert-log"
    __zert-log error 1 "Error message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;31m[ZERT]: ❌ Error message (1)\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_error_outputs_emoji_when_icon_style_is_emoji

function test_zert_log_uses_zstyle_icon_style_when_no_env_var {
    reset_env
    zstyle ':zert:log' icon-style emoji
    source "$HERE/../lib/__zert-log"
    __zert-log info "Info message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;34m[ZERT]: ℹ️ Info message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_uses_zstyle_icon_style_when_no_env_var

function test_zert_log_defaults_to_nerd_icon_when_no_config {
    reset_env
    source "$HERE/../lib/__zert-log"
    __zert-log info "Info message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;34m[ZERT]: \uf05a Info message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_defaults_to_nerd_icon_when_no_config

function test_zert_log_highlights_text_in_curly_braces_with_cyan {
    reset_env
    ZERT_ICON_STYLE="nerd"
    source "$HERE/../lib/__zert-log"
    __zert-log info "This is a {{highlighted}} message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;34m[ZERT]: \uf05a This is a \033[1;36mhighlighted\033[1;34m message\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_highlights_text_in_curly_braces_with_cyan

function test_zert_log_error_with_error_code_and_highlighted_text {
    reset_env
    ZERT_ICON_STYLE="emoji"
    source "$HERE/../lib/__zert-log"
    __zert-log error 42 "This is an {{error}} message" >$TEMP_OUT 2>$TEMP_ERR
    assert_equals "" "$(cat $TEMP_OUT)" && \
    assert_equals $'\033[1;31m[ZERT]: ❌ This is an \033[1;36merror\033[1;31m message (42)\033[0m' "$(cat $TEMP_ERR)"
}
test_case test_zert_log_error_with_error_code_and_highlighted_text

test_summary
