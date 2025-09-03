#!/usr/bin/env bash
set -uo pipefail   # safer defaults (but not `-e`, we’ll handle errors manually)

mkdir -p trivy-reports
failed=0

# Find all images
images=$(grep -rhoP 'image:\s*\K\S+' stack/stack.yml | sort -u)

for img in $images; do
  echo "🔍 Processing $img ..."

  if ! docker image inspect "$img" >/dev/null 2>&1; then
    echo "📥 Pulling missing image: $img"
    docker pull "$img" || failed=1
  fi

  safe_name=$(echo "$img" | tr '/:' '__')
  trivy image \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    --format table \
    --output "trivy-reports/${safe_name}.txt" \
    "$img" || failed=1
done

# Analyze reports
for file in trivy-reports/*.txt; do
  if awk '/^==========$/ { getline; if ($0 !~ /Total: 0/) exit 1 }' "$file"; then
    echo "✅ No issues in $file"
  else
    echo "❌ Found issues in $file"
    failed=1
  fi
done

# Decide outcome
if [ "$failed" -eq 1 ]; then
  if [ "${ACCEPT_RISK:-false}" = "true" ]; then
    echo "⚠️  Continuing despite the risk..."
    exit 0
  else
    echo "❌ Risks not accepted. Exiting..."
    exit 1
  fi
else
  echo "✅ No critical issues found"
fi
