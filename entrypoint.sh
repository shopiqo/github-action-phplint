#!/bin/bash

set -xe

COMPOSER_HOME="/root/.composer"
LINTER_PATH="${COMPOSER_HOME}/vendor/bin/phplint -vvv"
CONFIG_FILE="${INPUT_CONFIG_FILE}"
TARGET_PATH="${INPUT_PATH:-/workdir}"

if [ ! -z "${GITHUB_WORKSPACE}" ]; then
  WORKSPACE=$GITHUB_WORKSPACE
elif [ ! -z "${CI_PROJECT_DIR}" ]; then
  WORKSPACE=$CI_PROJECT_DIR
else
  WORKSPACE="/workdir"
fi

cd $WORKSPACE; 

if [ -f "$CONFIG_FILE" ]; then
    CMD="$LINTER_PATH -c $CONFIG_FILE -- $TARGET_PATH"
else
    if [ -n "$CONFIG_FILE" ]; then
        echo "Config file not found: $CONFIG_FILE"
        echo "Current directory files:"
        ls -la
    fi

    CMD="$LINTER_PATH --no-configuration"

    if [ "$INPUT_WARNING" = "true" ]; then
        CMD="$CMD --warning"
    fi

    IFS=',' read -ra EXCLUDES <<< "$INPUT_EXCLUDE"
    for exclude in "${EXCLUDES[@]}"; do
        CMD="$CMD --exclude=$exclude"
    done

    IFS=',' read -ra EXTENSIONS <<< "$INPUT_EXTENSIONS"
    for extension in "${EXTENSIONS[@]}"; do
        CMD="$CMD --extensions=$extension"
    done

    CMD="$CMD --jobs=${INPUT_JOBS}"
    CMD="$CMD -- $TARGET_PATH"
fi

sh -c "$CMD"
