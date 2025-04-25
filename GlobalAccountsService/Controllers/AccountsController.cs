using GlobalAccountsService.Models;
using GlobalAccountsService.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Newtonsoft.Json;


// using Styra.Opa;
using Styra.Ucast.Linq;
// using System.Linq;
using System.Net.Http.Headers;
using System.Net.Mime;
using System.Text.Json;
// using static Newtonsoft.Json.JsonConvert;



namespace GlobalAccountsService.Controllers;

public struct CompileUCASTResult
{
    [JsonProperty("result")]
    public CompileResult Result;

    public struct CompileResult
    {
        [JsonProperty("query", NullValueHandling = NullValueHandling.Ignore)]
        public UCASTNode? Query;
    }
}

[Route("v1/g/accounts")]
[ApiController]
[Produces(MediaTypeNames.Application.Json)]
[Consumes(MediaTypeNames.Application.Json)]
public class AccountsController : ControllerBase
{
    private readonly ILogger<AccountsController> _logger;
    private readonly HttpClient _httpClient = new HttpClient();
    private readonly IAccountsRepository _repository;

    // private readonly OpaClient _opaClient;

    // public AccountsController(IAccountsRepository repository, ILogger<AccountsController> logger, ILogger<OpaClient> opaLogger)
    public AccountsController(IAccountsRepository repository, ILogger<AccountsController> logger)
    {
        _repository = repository;
        _logger = logger;
        // _opaClient = new OpaClient("http://localhost:8181/", opaLogger);
    }

    [HttpGet("{id}")]
    public ActionResult<Account> GetAccountById(String id)
    {
        var account = _repository.GetAccountById(id);
        if (account == null)
        {
            return NotFound();
        }
        return Ok(account);
    }

    [HttpGet]
    public ActionResult<IEnumerable<Account>> GetAccounts()
    {
        var filters = getFilters(Request.Headers);

        var accounts = _repository.GetAccounts()
            .Where(a => a.Manager.isUs == false)
            .OrderBy(a => a.AccountId)
            .AsQueryable();

        if (filters.Result != null && filters.Result.Type != null)
        {
            accounts = accounts.ApplyUCASTFilter(filters.Result, new MappingConfiguration<Account>(new Dictionary<string, string> { { "balance", "account.balance" } }, prefix: "account"));
        }

        return Ok(accounts);
    }

    private async Task<UCASTNode> getFilters(IHeaderDictionary requestHeaders)
    {
        var policyRequest = new
        {
            input = new
            {
                attributes = new
                {
                    request = new
                    {
                        http = new
                        {
                            headers = requestHeaders.ToDictionary(h => h.Key.ToLowerInvariant(), h => h.Value.ToString())
                        }
                    }
                }
            }
        };

        var policyRequestJson = System.Text.Json.JsonSerializer.Serialize(policyRequest);
        var content = new StringContent(policyRequestJson, System.Text.Encoding.UTF8, "application/json");

        var request = new HttpRequestMessage(HttpMethod.Post, "http://localhost:8181/v1/compile/policy/app/filter");
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.styra.ucast.linq+json"));
        request.Content = content;
        _logger.LogInformation("Sending request: {Method} {Uri} with headers: {Headers} and body: {Body}",
            request.Method, request.RequestUri, request.Headers, policyRequestJson);

        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();

        string json = await response.Content.ReadAsStringAsync();

        CompileUCASTResult node = JsonConvert.DeserializeObject<CompileUCASTResult>(json);

        return node.Result.Query;
    }

    [HttpPost("/txfr/{fromId}/{toId}/{amount}")]
    public IActionResult TransferAmount(String fromId, String toId, float amount)
    {
        _repository.TransferFunds(fromId, toId, amount);
        return Ok();
    }

    [HttpPatch("{id}")]
    public IActionResult ReactivateAccount(String id)
    {
        _repository.ReactivateAccount(id);
        return Ok();
    }

    [HttpDelete("{id}")]
    public IActionResult CloseAccount(String id)
    {
        _repository.CloseAccount(id);
        return Ok();
    }
}
