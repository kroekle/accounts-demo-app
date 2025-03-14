using GlobalAccountsService.Models;

namespace GlobalAccountsService.Repositories
{
    public interface IAccountsRepository
    {
        Account GetAccountById(String accountId);
        IEnumerable<Account> GetAccounts();
        void TransferFunds(String fromAccount, String toAccount, decimal amount);
        void ReactivateAccount(String accountId);
        void CloseAccount(String accountId);
    }
}