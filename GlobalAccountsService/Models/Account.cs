using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GlobalAccountsService.Models
{
    [Table("account")]
    public class Account
    {
        using Newtonsoft.Json;

        [JsonProperty("id")]
    [Key]
    [Column("account_id")]
    [Required]
    public int AccountId { get; set; }
    [Column("holder_name")]
    [Required]
    public string HolderName { get; set; } = string.Empty;
    [Column("balance")]
    [Required]
    public decimal Balance { get; set; } = 0;

    [Column("account_status")]
    public string Status { get; set; } = "INACTIVE";

    [Column("manager_id")]
    [Required]
    public int ManagerId { get; set; }

    [ForeignKey("ManagerId")]
    public Manager Manager { get; set; }

    [JsonProperty("region")]
    [Column("region")]
    [Required]
    public string AccountRegion { get; set; } = string.Empty;
}
}