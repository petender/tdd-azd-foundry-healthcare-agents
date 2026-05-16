## Screenshot Capture Checklist - foundry-healthcare-agents

Manual screenshot capture is required for this scenario because automated
Playwright capture was unavailable in this execution environment.

Save all screenshots in this folder using the exact filenames below.

## Category A: Azure Portal Screenshots (Infrastructure)

- `resource-group-overview.png`
- `deployment-history.png`
- `foundry-hub-overview.png`
- `foundry-project-overview.png`
- `openai-gpt4o-deployment.png`
- `ai-search-overview.png`
- `appservice-overview.png`
- `appservice-configuration.png`
- `appservice-identity.png`
- `appinsights-live-metrics.png`
- `appinsights-logs.png`

## Category B: Application Screenshots (Web App)

- `homepage.png`
- `triage-interaction.png`
- `scheduler-interaction.png`
- `medication-interaction.png`
- `faq-interaction.png`

## Capture Guidance

1. Sign in to Azure Portal with an account that can access
   `rg-foundry-healthcare-agents`.
2. Capture full browser viewport for each required blade.
3. For app screenshots, use the deployed site:
   https://app-fha-dev-qp5yn2.azurewebsites.net/
4. Ensure no sensitive values are visible (for example, secret values).
5. Keep image resolution consistent for clean embedding in the demo guide.

## Portal Starting Link

https://portal.azure.com/#@/resource/subscriptions/498ab842-278f-45f8-ac5c-dc89061565cd/resourceGroups/rg-foundry-healthcare-agents/overview

## Validation

Before delivery, confirm all files exist:

```powershell
Get-ChildItem ./generated-scenarios/foundry-healthcare-agents/demoguide/images/*.png |
  Select-Object -ExpandProperty Name
```
