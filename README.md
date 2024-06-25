# Clinical Trials Custom Copilot

I'm a Sr. Architect and Responsible AI Champ at Microsoft, Industry Solutions Delivery, Healthcare and Life Science OU and have extensive experience, over 24 years in the industry. I've always tied technology to their use cases and what problems it can solve and the business outcomes. I am very technical, a background in computer engineering, computer science, programming and development but approaching solutions only from a technical perpsective hasn't always panned out without looking at how it'll be used and who's using it.

## Idea
- I wanted to learn hands-on Azure OpenAI resources, model deployments of i.e. chat model (e.g. `gpt-35-turbo-16k`, `gpt-4`) with some kind of use case in mind.
- Since I'm in the Healthcare and Life Science industry, I was looking for use cases that could be helpful and ended asking "Is there a way to search Clinical Trials data using ChatGPT?" Of course, there are other ways to search clinical trials via ClinicalTrials.gov and the dataset is public but wanted to combine OpenAI + AI Search + ChatGPT.
- So, I embarked on answering this question and learning along the way  ended up deploying the following components:
  - Azure OpenAI Service
  - Blob Storage (Several ways to get data here: https://classic.clinicaltrials.gov/ct2/resources/download. I just went with a simple storage so I can house the XML files)
  - Azure AI Search Index
  - A Chat App UX (Luckily there is a sample app available I can use to start from https://github.com/microsoft/sample-app-aoai-chatGPT/). I've cloned that repo to start the clinical trials copilot repo.
  - Azure CosmosDB to store chat history (this is also included in the sample AOAI chat app)
  - PowerBI to view chat data from CosmosDB

## Conceptual Architecture
![image](https://github.com/dondinulos/clinical-trials-copilot/assets/10526770/528bd438-b1a5-4fa0-af22-2a15ba8aba2c)



## Azure Open AI
Just create a Standard Tier Azure OpenAI Service to build your own secure copilot and generative AI applications.

## Data Source / Blob Storage
Uploaded XML files from https://classic.clinicaltrials.gov/AllPublicXML.zip into my blob storage account.
![image](https://github.com/dondinulos/clinical-trials-copilot/assets/10526770/ecd7a275-95ee-4c04-a152-51db513a1a5b)


## AI Search
Configured Azure AI Search and created an Indexer to index the xml files from the Blob storage.
![image](https://github.com/dondinulos/clinical-trials-copilot/assets/10526770/ebc10584-bf17-4a30-ab59-21b72e7ee498)


## AI Studio
Adding the AI Search Index in AI Studio playground to test the data.
![image](https://github.com/dondinulos/clinical-trials-copilot/assets/10526770/d639cf1a-8823-4921-a9d0-e2c3c982bcd3)


## Chat App UX
Using the Open AI Sample Chat App, was able to deploy the app. NOTE: Don't use the One-click deploy to Azure Deployment as it uses an image from a countainer that may not be up to date with the latest code, use the Deploy with the Azure CLI instead using `az webapp up...'

![image](https://github.com/dondinulos/clinical-trials-copilot/assets/10526770/fc4ae921-61ac-4062-8202-b7a0448f5dbb)
![image](https://github.com/dondinulos/clinical-trials-copilot/assets/10526770/78545c5e-acca-477c-adc7-5bc2c33238cf)

## Sample Prompts
- Can you tell me colon cancer clinical trials? 
- Are there any clinical trials for breast cancer?
- What are the requirements to participate in the breast cancer study?
- Are there any clinical trials for multiple myeloma?
- Any there any clinical trials dealing with adverse symptoms of Covid?
- Can you find me clinical trials for Tourette Syndrome?
- Are there any lung cancer clinical trials in Washington, D.C.?
-- What about in California?
- What are the inclusion criteria for colon cancer clinical trials?
- What treatments are available for colon cancer?
- What is tamoxifen used for?
- What is invasive breast cancer?
- What are biomarkers?
- What’s the mortality rate for breast cancer?
- What’s the survivability rate for colon cancer?
- Are there any foods that I shouldn't eat if I have breast cancer?

## PowerBI
Connect PowerBI.com or PowerBI Desktop to the Azure CosmosDB and do a word cloud. The PBIX file is under: **powerbi/Clinical Trials Copilot Conversations.pbix**
![image](https://github.com/dondinulos/clinical-trials-copilot/assets/10526770/0b6617f8-b369-4cca-ac0f-ea4276212b7d)

## Learnings
- Copilot summarizes the number clinical trials it found and doesn’t return all from ClinicalTrials.gov.
- The maximum number of results is capped at 20 but sometimes returns less than this depending on the prompt.
- Because it’s public data, the out-of-the-box Microsoft Copilot will already provide some details about clinical trials from ClinicalTrials.gov. This excercise would be beneficial if the data is not public and want to "Bring your own data".


## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
