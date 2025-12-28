#!/bin/bash
set -e

echo "Detecting changed services..."

CURRENT_COMMIT=$(git rev-parse HEAD)
CHANGED_FILES=$(git diff --name-only HEAD~1 2>/dev/null || git diff --name-only)

SERVICES=("product-service" "inventory-service" "payment-service" "frontend")

mkdir -p .versions
> changed-services.txt

for service in "${SERVICES[@]}"; do

  if echo "$CHANGED_FILES" | grep -q "^$service/"; then

    SERVICE_NAME="${service/-service/}"

    VERSION_FILE=".versions/${SERVICE_NAME}.version"
    COMMIT_FILE=".versions/${SERVICE_NAME}.commit"

    # Initialize files if missing
    [ ! -f "$VERSION_FILE" ] && echo 0 > "$VERSION_FILE"
    [ ! -f "$COMMIT_FILE" ] && echo "" > "$COMMIT_FILE"

    LAST_COMMIT=$(cat "$COMMIT_FILE")

    if [ "$LAST_COMMIT" == "$CURRENT_COMMIT" ]; then
      echo "$service already processed for this commit (no version bump)"
      continue
    fi

    CURRENT_VERSION=$(cat "$VERSION_FILE")
    NEW_VERSION=$((CURRENT_VERSION + 1))

    echo "$NEW_VERSION" > "$VERSION_FILE"
    echo "$CURRENT_COMMIT" > "$COMMIT_FILE"

    IMAGE_NAME="${SERVICE_NAME}:v${NEW_VERSION}"

    echo "$service $IMAGE_NAME" >> changed-services.txt

    echo "$service changed → version v${NEW_VERSION}"

  else
    echo "$service not changed"
  fi

done

if [ ! -s changed-services.txt ]; then
  echo "No services changed"
fi
