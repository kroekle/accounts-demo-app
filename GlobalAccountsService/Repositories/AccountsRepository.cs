using GlobalAccountsService.Data;
using GlobalAccountsService.Models;
using Microsoft.EntityFrameworkCore;

namespace GlobalAccountsService.Repositories
{
    public class AccountsRepository : IAccountsRepository
    {
        private readonly AccountsContext _context;

        public AccountsRepository(AccountsContext context)
        {
            _context = context;
        }

        public Account GetAccountById(String id)
        {
            if (int.TryParse(id, out int accountId))
            {
                return _context.Accounts.Include(a => a.Manager).FirstOrDefault(a => a.AccountId == accountId);
            }
            return null;
        }

        public IEnumerable<Account> GetAccounts()
        {
            return _context.Accounts.Include(a => a.Manager).ToList();
        }


        public void TransferFunds(String fromId, String toId, decimal amount)
        {
            if (int.TryParse(fromId, out int fromAccountId) && int.TryParse(toId, out int toAccountId))
            {
                var fromAccount = _context.Accounts.Find(fromAccountId);
                var toAccount = _context.Accounts.Find(toAccountId);

                if (fromAccount != null && toAccount != null && fromAccount.Balance >= amount)
                {
                    fromAccount.Balance -= amount;
                    toAccount.Balance += amount;

                    _context.SaveChanges();
                }
            }
        }
        public void ReactivateAccount(String id)
        {
            if (int.TryParse(id, out int accountId))
            {
                var account = _context.Accounts.Find(accountId);
                if (account != null)
                {
                    account.Status = "ACTIVE";
                    _context.SaveChanges();
                }
            }
        }

        public void CloseAccount(String id)
        {
            if (int.TryParse(id, out int accountId))
            {
                var account = _context.Accounts.Find(accountId);
                if (account != null)
                {
                    account.Status = "INACTIVE";
                    _context.SaveChanges();
                }
            }
        }
    }
}