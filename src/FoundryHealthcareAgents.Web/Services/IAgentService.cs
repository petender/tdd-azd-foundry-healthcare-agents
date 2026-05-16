using FoundryHealthcareAgents.Web.Models;

namespace FoundryHealthcareAgents.Web.Services;

public interface IAgentService
{
    List<AgentProfile> GetAgents();
    AgentProfile? GetAgent(string agentId);
    List<HealthcareScenario> GetScenarios();
    Task<string> ChatAsync(string agentId, List<ChatMessage> history, CancellationToken cancellationToken = default);
    bool IsConfigured { get; }
}
