# Architect Webinar Series 13 December 2024

For the Architect Webinar on 13 December 2024 we demoed deployment of an Agentforce Agent with a Prompt Template action from one org to another. The Prompt Template uses Retrieval Augmented Generation (RAG) with Data Cloud and since the API name of the retriever is dynamic some processsing is required. The repo shows how to find the retriever API name in an org and then replace the API name during deployment.

Getting information about retrievers in an org can be done with the `/services/data/v62.0/ssot/machine-learning/retrievers` REST endpoint. In the repo there are two scripts that uses this to extract information.

### `script/get_retriever.sh` 
This script is used to extract a retriever API name. The script should be called with parts of the retriever label and optionally the org to connect to (if ommitted the default org is used).

``` bash
./script/get_retriever.sh File_Santa_Secret_Stash
```
``` bash
./script/get_retriever.sh File_Santa_Secret_Stash aws-20241213-deploy-org
```

### `script/list_retrievers.sh`
This script is used to list the retrievers in an org as a JSON structure. It outputs array with the label and the API name. The script should be called with parts of the retriever label and optionally the org to connect to (if ommitted the default org is used).

``` bash
./script/list_retrievers.sh
```
``` bash
./script/list_retrievers.sh aws-20241213-deploy-org
```

## Requirements
* `sf`
* `jq`
* `sponge`

## Retrieve metadata
```bash 
TARGET_ORG="aws-20241213"; sf project retrieve start -m GenAiFunction -m GenAiPlugin -m GenAiPlanner:Robin_s_Service_Agent -m GenAiPromptTemplate:Hybrid_Search --target-org $TARGET_ORG

FILENAME="force-app/main/default/genAiPromptTemplates/Hybrid_Search.genAiPromptTemplate-meta.xml" && cat $FILENAME | sed -E 's/RagFileUDMO_SI_[_a-z0-9]+/REPLACE_RETRIEVER/gi' | sponge $FILENAME
```

## Deploy metadata
```bash
TARGET_ORG="aws-20241213-deploy-org"; sf org assign permset -n EinsteinGPTPromptTemplateManager --target-org $TARGET_ORG
TARGET_ORG="aws-20241213-deploy-org"; RETRIEVER=`./scripts/get_retriever.sh File_Santa_Secret_Stash $TARGET_ORG` sf project deploy start --dry-run --target-org $TARGET_ORG
```
