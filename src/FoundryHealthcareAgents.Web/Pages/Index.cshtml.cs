using FoundryHealthcareAgents.Web.Models;
using FoundryHealthcareAgents.Web.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace FoundryHealthcareAgents.Web.Pages;

public class IndexModel(IAgentService agentService) : PageModel
{
    public List<AgentProfile> Agents { get; private set; } = [];
    public List<HealthcareScenario> Scenarios { get; private set; } = [];
    public bool IsConfigured => agentService.IsConfigured;

    public void OnGet()
    {
        Agents = agentService.GetAgents();
        Scenarios = agentService.GetScenarios();
    }
}
