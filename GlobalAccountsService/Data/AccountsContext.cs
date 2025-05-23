using Microsoft.EntityFrameworkCore;
using GlobalAccountsService.Models;

namespace GlobalAccountsService.Data
{
    public class AccountsContext : DbContext
    {
        public AccountsContext(DbContextOptions<AccountsContext> options) : base(options) { }

        public DbSet<Account> Accounts { get; set; }
        public DbSet<Manager> Managers { get; set; }
    }
}