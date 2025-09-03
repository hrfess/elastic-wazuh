#!/usr/bin/env bash
set -uo pipefail
mkdir -p yaml-reports
touch yaml-reports/yamllint-report.log
FILES=$(git ls-files '*.yml' '*.yaml')
if [ -n "$FILES" ]; then
	yamllint $FILES >> yaml-reports/yamllint-report.log
fi