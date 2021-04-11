 #!/bin/sh

set -eu
set -o pipefail

cd terraform
terraform apply -input=false -no-color -auto-approve | \
  tfnotify apply
