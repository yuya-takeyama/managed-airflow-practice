#!/bin/bash

set -eu
set -o pipefail

aws s3 sync --delete environments s3://yuyat-apache-airflow-test
