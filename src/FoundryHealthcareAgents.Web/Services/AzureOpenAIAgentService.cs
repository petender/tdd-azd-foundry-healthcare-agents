using System.Text.Json;
using Azure;
using Azure.AI.OpenAI;
using Azure.Identity;
using FoundryHealthcareAgents.Web.Models;

namespace FoundryHealthcareAgents.Web.Services;

public class AzureOpenAIAgentService : IAgentService
{
    private readonly OpenAI.Chat.ChatClient? _chatClient;
    private readonly List<AgentProfile> _agents;
    private readonly List<HealthcareScenario> _scenarios;
    private readonly ILogger<AzureOpenAIAgentService> _logger;

    public bool IsConfigured => _chatClient is not null;

    public AzureOpenAIAgentService(IConfiguration configuration, ILogger<AzureOpenAIAgentService> logger)
    {
        _logger = logger;
        _agents = LoadSeedData<List<AgentProfile>>("Data/agents.json") ?? [];
        _scenarios = LoadSeedData<List<HealthcareScenario>>("Data/scenarios.json") ?? [];

        var endpoint = configuration["AZURE_OPENAI_ENDPOINT"]
            ?? configuration["AzureOpenAI:Endpoint"];
        var deployment = configuration["AZURE_OPENAI_DEPLOYMENT"]
            ?? configuration["AzureOpenAI:DeploymentName"]
            ?? "gpt-4o";

        if (string.IsNullOrEmpty(endpoint))
        {
            _logger.LogWarning("Azure OpenAI endpoint not configured. Chat functionality disabled.");
            return;
        }

        var client = new AzureOpenAIClient(new Uri(endpoint), new DefaultAzureCredential());
        _chatClient = client.GetChatClient(deployment);
    }

    public List<AgentProfile> GetAgents() => _agents;

    public AgentProfile? GetAgent(string agentId) =>
        _agents.FirstOrDefault(a => a.Id == agentId);

    public List<HealthcareScenario> GetScenarios() => _scenarios;

    public async Task<string> ChatAsync(string agentId, List<ChatMessage> history, CancellationToken cancellationToken = default)
    {
        if (_chatClient is null)
            return "⚠️ Azure OpenAI is not configured. Set the AZURE_OPENAI_ENDPOINT environment variable to enable chat.";

        var agent = GetAgent(agentId);
        if (agent is null)
            return "Agent not found.";

        var messages = new List<OpenAI.Chat.ChatMessage>
        {
            new OpenAI.Chat.SystemChatMessage(agent.SystemPrompt)
        };

        foreach (var msg in history)
        {
            if (msg.Role == "user")
                messages.Add(new OpenAI.Chat.UserChatMessage(msg.Content));
            else if (msg.Role == "assistant")
                messages.Add(new OpenAI.Chat.AssistantChatMessage(msg.Content));
        }

        var completion = await _chatClient.CompleteChatAsync(messages, cancellationToken: cancellationToken);
        return completion.Value.Content[0].Text;
    }

    private static T? LoadSeedData<T>(string relativePath)
    {
        var fullPath = Path.Combine(AppContext.BaseDirectory, relativePath);
        if (!File.Exists(fullPath))
        {
            fullPath = Path.Combine(Directory.GetCurrentDirectory(), relativePath);
        }
        if (!File.Exists(fullPath))
            return default;

        var json = File.ReadAllText(fullPath);
        return JsonSerializer.Deserialize<T>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
    }
}
