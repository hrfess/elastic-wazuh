#!/usr/bin/env bash
set -uo pipefail
mkdir -p yaml-reports
touch yaml-reports/yamllint-report.log
FILES=$(git ls-files '*.yml' '*.yaml')
if [ -n "$FILES" ]; then
	yamllint $FILES > yaml-reports/yamllint-report.log
fi
one=$(grep error  yaml-reports/yamllint-report.log)
if (( $one == 1 )); then
	exit 0
fi
if [ "${ACCEPT_RISK}" = "true" ]; then
	exit 0
fi