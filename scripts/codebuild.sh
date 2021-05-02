#!/bin/bash

set -eu
set -o pipefail

if [ "$CODEBUILD_WEBHOOK_TRIGGER" = "branch/main" ]; then
  DRY_RUN=false
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "Running dry-run mode"
  ./scripts/dryrun.sh
else
  echo "Running deploy"
  ./scripts/sync.sh
fi
