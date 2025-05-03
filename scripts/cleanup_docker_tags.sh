#!/bin/bash

# Docker Hub credentials
DOCKERHUB_USERNAME="happys4656"
DOCKERHUB_TOKEN="$1"  # Pass token as an argument
REPO_NAME="$2"  # Pass repo name as an argument (e.g., happys4656/ecomm-app)
TAGS_TO_KEEP=5

# Step 1: Get a JWT token for authentication
JWT_TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_TOKEN\"}" https://hub.docker.com/v2/users/login/ | jq -r .token)

if [ -z "$JWT_TOKEN" ]; then
    echo "Failed to authenticate with Docker Hub"
    exit 1
fi

# Step 2: List all tags for the repository
TAGS=$(curl -s -H "Authorization: JWT $JWT_TOKEN" "https://hub.docker.com/v2/repositories/$REPO_NAME/tags/?page_size=100" | jq -r '.results[].name')

# Step 3: Sort tags and exclude 'latest'
FILTERED_TAGS=$(echo "$TAGS" | grep -v '^latest$' | sort -nr)

# Step 4: Identify tags to keep and delete
TOTAL_TAGS=$(echo "$FILTERED_TAGS" | wc -l)
TAGS_TO_DELETE=$((TOTAL_TAGS - TAGS_TO_KEEP))

if [ $TAGS_TO_DELETE -le 0 ]; then
    echo "No tags to delete in $REPO_NAME. Total tags: $TOTAL_TAGS, keeping: $TAGS_TO_KEEP"
    exit 0
fi

# Step 5: Get the tags to delete (older ones)
TAGS_TO_DELETE_LIST=$(echo "$FILTERED_TAGS" | tail -n $TAGS_TO_DELETE)

# Step 6: Delete the older tags
for TAG in $TAGS_TO_DELETE_LIST; do
    echo "Deleting tag in $REPO_NAME: $TAG"
    DELETE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: JWT $JWT_TOKEN" -X DELETE "https://hub.docker.com/v2/repositories/$REPO_NAME/tags/$TAG/")
    if [ "$DELETE_RESPONSE" -eq 204 ]; then
        echo "Successfully deleted tag: $TAG"
    else
        echo "Failed to delete tag: $TAG (HTTP status: $DELETE_RESPONSE)"
    fi
done

echo "Cleanup complete for $REPO_NAME. Kept the latest $TAGS_TO_KEEP tags."
