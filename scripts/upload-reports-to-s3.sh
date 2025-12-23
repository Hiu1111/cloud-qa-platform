#!/usr/bin/env bash
set -euo pipefail

: "${S3_BUCKET:?Set S3_BUCKET env var}"
: "${S3_PREFIX:=qa-reports}"
: "${BUILD_TAG:=local}"

REPORT_DIR="target/surefire-reports"

if [ ! -d "$REPORT_DIR" ]; then
  echo "No reports found at $REPORT_DIR"
  exit 0
fi

aws s3 cp "$REPORT_DIR" "s3://${S3_BUCKET}/${S3_PREFIX}/${BUILD_TAG}/" --recursive
echo "Uploaded reports to s3://${S3_BUCKET}/${S3_PREFIX}/${BUILD_TAG}/"
