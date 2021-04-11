#!/bin/sh

set -eu
set -o pipefail

cd terraform
terraform plan -input=false -no-color | \
  tfnotify plan
