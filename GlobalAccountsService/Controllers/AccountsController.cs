using GlobalAccountsService.Models;
using GlobalAccountsService.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GlobalAccountsService.Controllers
{
    [Route("v1/g/accounts")]
    [ApiController]
    public class AccountsController : ControllerBase
    {
        private readonly IAccountsRepository _repository;

        public AccountsController(IAccountsRepository repository)
        {
            _repository = repository;
        }

        [HttpGet("{id}")]
        public ActionResult<Account> GetAccountById(int id)
        {
            var account = _repository.GetAccountById(id);
            if (account == null)
            {
                return NotFound();
            }
            return account;
        }

        [HttpGet]
        public ActionResult<IEnumerable<Account>> GetAccounts()
        {
            return Ok(_repository.GetAccounts());
        }

        [HttpPost("/txfr/{fromId}/{toId}/{amount}")]
        public IActionResult TransferAmount(int fromId, int toId, decimal amount)
        {
            _repository.TransferFunds(fromId, toId, amount);
            return NoContent();
        }

        [HttpPatch("{id}")]
        public IActionResult ReactivateAccount(int id)
        {
            _repository.ReactivateAccount(id);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public IActionResult CloseAccount(int id)
        {
            _repository.CloseAccount(id);
            return NoContent();
        }
    }
}