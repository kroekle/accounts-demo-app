using GlobalAccountsService.Models;

namespace GlobalAccountsService.Repositories
{
    public interface IAccountsRepository
    {
        Account GetAccountById(int accountId);
        IEnumerable<Account> GetAccounts();
        void TransferFunds(int fromAccount, int toAccount, decimal amount);
        void ReactivateAccount(int accountId);
        void CloseAccount(int accountId);
    }
}