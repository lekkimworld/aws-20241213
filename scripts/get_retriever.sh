#!/bin/bash
if [ -z "$2" ]; then
    TARGET_ORG=""
else
    TARGET_ORG="--target-org $2"
fi
INSTANCE_URL=`sf org display --json $TARGET_ORG 2> /dev/null | jq ".result.instanceUrl" -r`
if [ "$INSTANCE_URL" = "null" ]; then
    echo "Unable to find instanceUrl in result"
    exit 1
fi
ACCESS_TOKEN=`sf org display --json $TARGET_ORG 2> /dev/null | jq ".result.accessToken" -r`
if [ "$ACCESS_TOKEN" = "null" ]; then
    echo "Unable to find accessToken in result"
    exit 1
fi
RETRIEVER=`curl $INSTANCE_URL/services/data/v62.0/ssot/machine-learning/retrievers --silent -H "Authorization: Bearer $ACCESS_TOKEN" | jq ".retrievers[] | select(.activeConfiguration.label | contains(\"$1\")) | .name" -r`
echo $RETRIEVER
