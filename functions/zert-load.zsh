#!/usr/bin/env zsh
export function zert-load(){
    PLUGIN="$1"
    if [ -z "$PLUGIN" ]; then
        zert-load-print-help
    fi
}

function zert-load-print-help(){
    
}