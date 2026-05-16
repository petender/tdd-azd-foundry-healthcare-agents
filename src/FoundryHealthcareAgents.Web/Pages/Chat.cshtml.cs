using FoundryHealthcareAgents.Web.Models;
using FoundryHealthcareAgents.Web.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace FoundryHealthcareAgents.Web.Pages;

public class ChatModel(IAgentService agentService) : PageModel
{
    public AgentProfile? Agent { get; private set; }
    public string AgentId { get; private set; } = string.Empty;
    public string? InitialMessage { get; private set; }

    public IActionResult OnGet(string agentId, string? message = null)
    {
        AgentId = agentId;
        Agent = agentService.GetAgent(agentId);
        InitialMessage = message;

        if (Agent is null)
            return RedirectToPage("/Index");

        return Page();
    }

    public async Task<IActionResult> OnPostAsync([FromBody] ChatRequest request)
    {
        var response = await agentService.ChatAsync(
            request.AgentId,
            request.Messages,
            HttpContext.RequestAborted);

        return new JsonResult(new { reply = response });
    }
}

public class ChatRequest
{
    public string AgentId { get; set; } = string.Empty;
    public List<ChatMessage> Messages { get; set; } = [];
}
