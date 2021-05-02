#!/bin/bash

set -eu
set -o pipefail

aws s3 sync --dryrun --delete environments s3://yuyat-apache-airflow-test
