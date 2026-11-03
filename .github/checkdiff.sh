#!/bin/sh
set -e

# git diff-index trusts the index's cached stat data and reports a file as
# modified even when a build only rewrote it with identical content, so use
# the content-aware porcelain diff instead.
if ! git diff --quiet HEAD --; then
    echo 'Uncommitted changes detected:'
    git diff --name-status HEAD --
    return 1
fi
