# Clinical Trials Custom Copilot

I'm a Sr. Architect at Microsoft Industry Solutions Delivery, Healthcare and Life Science organization and have extensive experience over 24 years in the industry. I've always tied technology to their use cases and what problems it can solve and the business outcomes. I am very technical, a background in computer engineering, computer science and programming. But approaching solutions only from a technical perpsective hasn't always panned out without looking at how it'll be used.

## Idea
- I wanted to learn hands-on Azure OpenAI resources, model deployments of i.e. chat model (e.g. `gpt-35-turbo-16k`, `gpt-4`) with the use cases in mind.
- I asked myself "Is there a way to search Clinical Trials data using ChatGPT?" There are ways to search clinical trials via ClinicalTrials.gov and the dataset is public.
- So, I embarked on answering this question and I ended up deploying the following components:
  - Azure OpenAI Service
  - Blob Storage (Several ways to get data here: https://classic.clinicaltrials.gov/ct2/resources/download. I just went with a simple storage so I can house the XML files)
  - Azure AI Search Index
  - A Chat App UX (Luckily there is a sample app available I can use to start from https://github.com/microsoft/sample-app-aoai-chatGPT/)
  - Azure CosmosDB to store chat history (this is also included in the sample AOAI chat app)
  - PowerBI to view chat data from CosmosDB

## Azure Open AI

## Blob Storage

## AI Search

## AI Studio

## Chat App UX

## PowerBI


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
