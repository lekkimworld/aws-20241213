# Architect Webinar Series 13 December 2024

For the Architect Webinar on 13 December 2024 we demoed deployment of an Agentforce Agent with a Prompt Template action from one org to another. The Prompt Template uses Retrieval Augmented Generation (RAG) with Data Cloud and since the API name of the retriever is dynamic some processsing is required. The repo shows how to find the retriever API name in an org and then replace the API name during deployment.

Getting information about retrievers in an org can be done with the `/services/data/v62.0/ssot/machine-learning/retrievers` REST endpoint. In the repo there are two scripts that uses this to extract information.

The agent also needs to have a user specified - this is done in the `Bot` metadata. The user must have the `Einstein Agent User` profile and there are `PermissionSet` / `PermissionSetGroup` / `PermissionSetLicense` requirements as well (see below). The `PermissionSetLicens`'s seems to be set automatically at least when using the Apex in `scripts/apex/create_agent_user.apex`.

### PermissionSetLicenses
* `EinsteinGPTPromptTemplatesPsl`
* `GenieDataPlatformStarterPsl`
* `AgentforceServiceAgentUserPsl`

### PermissionSetGroups
* `AgentforceServiceAgentUserPsg`

### PermissionSets
* `AgentforceServiceAgentBase`

### `scripts/get_retriever.sh` 
This script is used to extract a retriever API name. The script should be called with parts of the retriever label and optionally the org to connect to (if ommitted the default org is used).

``` bash
./scripts/get_retriever.sh File_Santa_Secret_Stash
```
``` bash
./scripts/get_retriever.sh File_Santa_Secret_Stash aws-20241213-deploy-org
```

### `scripts/list_retrievers.sh`
This script is used to list the retrievers in an org as a JSON structure. It outputs array with the label and the API name. The script should be called with parts of the retriever label and optionally the org to connect to (if ommitted the default org is used).

``` bash
./scripts/list_retrievers.sh
```
``` bash
./scripts/list_retrievers.sh aws-20241213-deploy-org
```

## Requirements
* `sf`
* `jq`
* `sponge`

## Retrieve metadata
```bash 
TARGET_ORG="aws-20241213"; sf project retrieve start -m GenAiFunction -m GenAiPlugin -m GenAiPlanner:Robin_s_Service_Agent -m GenAiPromptTemplate:Hybrid_Search -m Bot:Santa_s_Little_Helper -m BotVersion:Santa_s_Little_Helper.v1 --target-org $TARGET_ORG

FILENAME="force-app/main/default/genAiPromptTemplates/Hybrid_Search.genAiPromptTemplate-meta.xml" && cat $FILENAME | sed -E 's/RagFileUDMO_SI_[_a-z0-9]+/REPLACE_RETRIEVER/gi' | sponge $FILENAME
FILENAME="force-app/main/default/bots/Santa_s_Little_Helper/Santa_s_Little_Helper.bot-meta.xml" && cat $FILENAME | sed -E 's/<botUser>[-._a-z0-9]+@[-._a-z0-9]+\.[a-z]+<\/botUser>/<botUser>REPLACE_AGENT_USERNAME<\/botUser>/i' | sponge $FILENAME
```

## Create Agent user
```bash
TARGET_ORG="aws-20241213-deploy-org" sf apex run -o $TARGET_ORG -f scripts/apex/create_agent_user.apex
```

## Deploy metadata
```bash
TARGET_ORG="aws-20241213-deploy-org"
export AGENT_USERNAME=`sf data query --target-org $TARGET_ORG -q "select username FROM User WHERE Name='Santa Agent User'" --json | jq ".result.records[0].Username" -r`
RETRIEVER=`./scripts/get_retriever.sh File_Santa_Secret_Stash $TARGET_ORG --silent` sf project deploy start --dry-run --target-org $TARGET_ORG
```

## Reset demo
```bash
rm -rf force-app/main/default/genAiPlanners force-app/main/default/genAiPlugins force-app/main/default/genAiPromptTemplates force-app/main/default/genAiFunctions force-app/main/default/bots && mkdir -p force-app/main/default
```
