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

        public Account GetAccountById(int id)
        {
            return _context.Accounts.Include(a => a.Manager).FirstOrDefault(a => a.AccountId == id);
        }

        public IEnumerable<Account> GetAccounts()
        {
            return _context.Accounts.Include(a => a.Manager).ToList();
        }


        public void TransferFunds(int fromId, int toId, decimal amount)
        {
            var fromAccount = _context.Accounts.Find(fromId);
            var toAccount = _context.Accounts.Find(toId);

            if (fromAccount != null && toAccount != null && fromAccount.Balance >= amount)
            {
                fromAccount.Balance -= amount;
                toAccount.Balance += amount;

                _context.SaveChanges();
            }
        }
        public void ReactivateAccount(int id)
        {
            var account = _context.Accounts.Find(id);
            if (account != null)
            {
                account.Status = "ACTIVE";
                _context.SaveChanges();
            }
        }

        public void CloseAccount(int id)
        {
            var account = _context.Accounts.Find(id);
            if (account != null)
            {
                account.Status = "INACTIVE";
                _context.SaveChanges();
            }
        }
    }
}