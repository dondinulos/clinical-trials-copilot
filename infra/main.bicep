targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment, used to generate a unique hash for all resources.')
param environmentName string

@minLength(1)
@description('Primary Azure region for all resources (e.g., eastus, westeurope).')
param location string

@description('Name of the App Service Plan. If not provided, a default will be generated.')
param appServicePlanName string = ''
@description('Name of the backend App Service. If not provided, a default will be generated.')
param backendServiceName string = ''
@description('Name of the main resource group. If not provided, a default will be generated.')
param resourceGroupName string = ''

@description('Name of the Azure Cognitive Search service. If not provided, a default will be generated.')
param searchServiceName string = ''
@description('Resource group for the search service. If not provided, uses main resource group.')
param searchServiceResourceGroupName string = ''
@description('Location for the search service resource group.')
param searchServiceResourceGroupLocation string = location
@description('SKU for the search service.')
param searchServiceSkuName string = ''
@description('Name of the search index.')
param searchIndexName string = 'gptkbindex'
@description('Enable semantic search.')
param searchUseSemanticSearch bool = false
@description('Semantic search config name.')
param searchSemanticSearchConfig string = 'default'
@description('Top K results for search.')
param searchTopK int = 5
@description('Enable in-domain search.')
param searchEnableInDomain bool = true
@description('Content columns for search.')
param searchContentColumns string = 'content'
@description('Filename column for search.')
param searchFilenameColumn string = 'filepath'
@description('Title column for search.')
param searchTitleColumn string = 'title'
@description('URL column for search.')
param searchUrlColumn string = 'url'

@description('Name of the Azure OpenAI resource. If not provided, a default will be generated.')
param openAiResourceName string = ''
@description('Resource group for the OpenAI resource. If not provided, uses main resource group.')
param openAiResourceGroupName string = ''
@description('Location for the OpenAI resource group.')
param openAiResourceGroupLocation string = location
@description('SKU for the OpenAI resource.')
param openAiSkuName string = ''
@description('Deployment name for the main OpenAI model.')
param openAIModel string = 'turbo16k'
@description('Name of the main OpenAI model.')
param openAIModelName string = 'gpt-35-turbo-16k'
@description('Temperature for OpenAI completions.')
param openAITemperature int = 0
@description('Top P for OpenAI completions.')
param openAITopP int = 1
@description('Max tokens for OpenAI completions.')
param openAIMaxTokens int = 1000
@description('Stop sequence for OpenAI completions.')
param openAIStopSequence string = ''
@description('System message for OpenAI completions.')
param openAISystemMessage string = 'You are an AI assistant that helps people find information.'
@description('API version for OpenAI.')
param openAIApiVersion string = '2023-06-01-preview'
@description('Enable streaming for OpenAI completions.')
param openAIStream bool = true
@description('Deployment name for embedding model.')
param embeddingDeploymentName string = 'embedding'
@description('Name of the embedding model.')
param embeddingModelName string = 'text-embedding-ada-002'

// Used by prepdocs.py: Form recognizer
@description('Name of the Form Recognizer service.')
param formRecognizerServiceName string = ''
@description('Resource group for the Form Recognizer service.')
param formRecognizerResourceGroupName string = ''
@description('Location for the Form Recognizer resource group.')
param formRecognizerResourceGroupLocation string = location
@description('SKU for the Form Recognizer service.')
param formRecognizerSkuName string = ''

// Used for the Azure AD application
@description('Client ID for Azure AD authentication.')
param authClientId string
@secure()
@description('Client secret for Azure AD authentication.')
param authClientSecret string

// Used for Cosmos DB
@description('Cosmos DB account name. If not provided, a default will be generated.')
param cosmosAccountName string = ''

@description('Id of the user or app to assign application roles.')
param principalId string = ''

var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

resource openAiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(openAiResourceGroupName)) {
  name: !empty(openAiResourceGroupName) ? openAiResourceGroupName : resourceGroup.name
}

resource searchServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(searchServiceResourceGroupName)) {
  name: !empty(searchServiceResourceGroupName) ? searchServiceResourceGroupName : resourceGroup.name
}


// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: resourceGroup
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B1'
      capacity: 1
    }
    kind: 'linux'
  }
}

// The application frontend
var appServiceName = !empty(backendServiceName) ? backendServiceName : '${abbrs.webSitesAppService}backend-${resourceToken}'
var authIssuerUri = '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'
module backend 'core/host/appservice.bicep' = {
  name: 'web'
  scope: resourceGroup
  params: {
    name: appServiceName
    location: location
    tags: union(tags, { 'azd-service-name': 'backend' })
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.10'
    scmDoBuildDuringDeployment: true
    managedIdentity: true
    authClientSecret: authClientSecret
    authClientId: authClientId
    authIssuerUri: authIssuerUri
    appSettings: {
      // search
      AZURE_SEARCH_INDEX: searchIndexName
      AZURE_SEARCH_SERVICE: searchService.outputs.name
      AZURE_SEARCH_KEY: searchService.outputs.adminKey
      AZURE_SEARCH_USE_SEMANTIC_SEARCH: searchUseSemanticSearch
      AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG: searchSemanticSearchConfig
      AZURE_SEARCH_TOP_K: searchTopK
      AZURE_SEARCH_ENABLE_IN_DOMAIN: searchEnableInDomain
      AZURE_SEARCH_CONTENT_COLUMNS: searchContentColumns
      AZURE_SEARCH_FILENAME_COLUMN: searchFilenameColumn
      AZURE_SEARCH_TITLE_COLUMN: searchTitleColumn
      AZURE_SEARCH_URL_COLUMN: searchUrlColumn
      // openai
      AZURE_OPENAI_RESOURCE: openAi.outputs.name
      AZURE_OPENAI_MODEL: openAIModel
      AZURE_OPENAI_MODEL_NAME: openAIModelName
      AZURE_OPENAI_KEY: openAi.outputs.key
      AZURE_OPENAI_TEMPERATURE: openAITemperature
      AZURE_OPENAI_TOP_P: openAITopP
      AZURE_OPENAI_MAX_TOKENS: openAIMaxTokens
      AZURE_OPENAI_STOP_SEQUENCE: openAIStopSequence
      AZURE_OPENAI_SYSTEM_MESSAGE: openAISystemMessage
      AZURE_OPENAI_PREVIEW_API_VERSION: openAIApiVersion
      AZURE_OPENAI_STREAM: openAIStream
    }
  }
}


module openAi 'core/ai/cognitiveservices.bicep' = {
  name: 'openai'
  scope: openAiResourceGroup
  params: {
    name: !empty(openAiResourceName) ? openAiResourceName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: openAiResourceGroupLocation
    tags: tags
    sku: {
      name: !empty(openAiSkuName) ? openAiSkuName : 'S0'
    }
    deployments: [
      {
        name: openAIModel
        model: {
          format: 'OpenAI'
          name: openAIModelName
          version: '0613'
        }
        capacity: 30
      }
      {
        name: embeddingDeploymentName
        model: {
          format: 'OpenAI'
          name: embeddingModelName
          version: '2'
        }
        capacity: 30
      }
    ]
  }
}

module searchService 'core/search/search-services.bicep' = {
  name: 'search-service'
  scope: searchServiceResourceGroup
  params: {
    name: !empty(searchServiceName) ? searchServiceName : 'gptkb-${resourceToken}'
    location: searchServiceResourceGroupLocation
    tags: tags
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    sku: {
      name: !empty(searchServiceSkuName) ? searchServiceSkuName : 'standard'
    }
    semanticSearch: 'free'
  }
}

// The application database
module cosmos 'db.bicep' = {
  name: 'cosmos'
  scope: resourceGroup
  params: {
    accountName: !empty(cosmosAccountName) ? cosmosAccountName : '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
    location: 'eastus'
    tags: tags
    principalIds: [principalId, backend.outputs.identityPrincipalId]
  }
}


// USER ROLES
module openAiRoleUser 'core/security/role.bicep' = {
  scope: openAiResourceGroup
  name: 'openai-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'User'
  }
}

module searchRoleUser 'core/security/role.bicep' = {
  scope: searchServiceResourceGroup
  name: 'search-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'User'
  }
}

module searchIndexDataContribRoleUser 'core/security/role.bicep' = {
  scope: searchServiceResourceGroup
  name: 'search-index-data-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: 'User'
  }
}

module searchServiceContribRoleUser 'core/security/role.bicep' = {
  scope: searchServiceResourceGroup
  name: 'search-service-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
    principalType: 'User'
  }
}

// SYSTEM IDENTITIES
module openAiRoleBackend 'core/security/role.bicep' = {
  scope: openAiResourceGroup
  name: 'openai-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'ServicePrincipal'
  }
}

module searchRoleBackend 'core/security/role.bicep' = {
  scope: searchServiceResourceGroup
  name: 'search-role-backend'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'ServicePrincipal'
  }
}

// For doc prep
module docPrepResources 'docprep.bicep' = {
  name: 'docprep-resources${resourceToken}'
  params: {
    location: location
    resourceToken: resourceToken
    tags: tags
    principalId: principalId
    resourceGroupName: resourceGroup.name
    formRecognizerServiceName: formRecognizerServiceName
    formRecognizerResourceGroupName: formRecognizerResourceGroupName
    formRecognizerResourceGroupLocation: formRecognizerResourceGroupLocation
    formRecognizerSkuName: !empty(formRecognizerSkuName) ? formRecognizerSkuName : 'S0'
  }
}
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = resourceGroup.name

output BACKEND_URI string = backend.outputs.uri

// search
output AZURE_SEARCH_INDEX string = searchIndexName
output AZURE_SEARCH_SERVICE string = searchService.outputs.name
output AZURE_SEARCH_SERVICE_RESOURCE_GROUP string = searchServiceResourceGroup.name
output AZURE_SEARCH_SKU_NAME string = searchService.outputs.skuName
output AZURE_SEARCH_KEY string = searchService.outputs.adminKey
output AZURE_SEARCH_USE_SEMANTIC_SEARCH bool = searchUseSemanticSearch
output AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG string = searchSemanticSearchConfig
output AZURE_SEARCH_TOP_K int = searchTopK
output AZURE_SEARCH_ENABLE_IN_DOMAIN bool = searchEnableInDomain
output AZURE_SEARCH_CONTENT_COLUMNS string = searchContentColumns
output AZURE_SEARCH_FILENAME_COLUMN string = searchFilenameColumn
output AZURE_SEARCH_TITLE_COLUMN string = searchTitleColumn
output AZURE_SEARCH_URL_COLUMN string = searchUrlColumn

// openai
output AZURE_OPENAI_RESOURCE string = openAi.outputs.name
output AZURE_OPENAI_RESOURCE_GROUP string = openAiResourceGroup.name
output AZURE_OPENAI_ENDPOINT string = openAi.outputs.endpoint
output AZURE_OPENAI_MODEL string = openAIModel
output AZURE_OPENAI_MODEL_NAME string = openAIModelName
output AZURE_OPENAI_SKU_NAME string = openAi.outputs.skuName
output AZURE_OPENAI_KEY string = openAi.outputs.key
output AZURE_OPENAI_EMBEDDING_NAME string = embeddingDeploymentName
output AZURE_OPENAI_TEMPERATURE int = openAITemperature
output AZURE_OPENAI_TOP_P int = openAITopP
output AZURE_OPENAI_MAX_TOKENS int = openAIMaxTokens
output AZURE_OPENAI_STOP_SEQUENCE string = openAIStopSequence
output AZURE_OPENAI_SYSTEM_MESSAGE string = openAISystemMessage
output AZURE_OPENAI_PREVIEW_API_VERSION string = openAIApiVersion
output AZURE_OPENAI_STREAM bool = openAIStream

// Used by prepdocs.py:
output AZURE_FORMRECOGNIZER_SERVICE string = docPrepResources.outputs.AZURE_FORMRECOGNIZER_SERVICE
output AZURE_FORMRECOGNIZER_RESOURCE_GROUP string = docPrepResources.outputs.AZURE_FORMRECOGNIZER_RESOURCE_GROUP
output AZURE_FORMRECOGNIZER_SKU_NAME string = docPrepResources.outputs.AZURE_FORMRECOGNIZER_SKU_NAME

// cosmos
output AZURE_COSMOSDB_ACCOUNT string = cosmos.outputs.accountName
output AZURE_COSMOSDB_DATABASE string = cosmos.outputs.databaseName
output AZURE_COSMOSDB_CONVERSATIONS_CONTAINER string = cosmos.outputs.containerName

output AUTH_ISSUER_URI string = authIssuerUri
