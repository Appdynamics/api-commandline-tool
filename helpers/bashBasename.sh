#!/bin/bash
# Source: https://github.com/dylanaraps/pure-bash-bible#get-the-base-name-of-a-file-path
bashBasename() {
    # Usage: basename "path"
    : "${1%/}"
    printf '%s\n' "${_##*/}"
}
