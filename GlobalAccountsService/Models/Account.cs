using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace GlobalAccountsService.Models
{
    [Table("account")]
    public class Account
    {

        [JsonPropertyName("id")]
        [NotMapped]
        public string AccountIdString
        {
            get => AccountId.ToString();
            set => AccountId = int.Parse(value);
        }

        [JsonIgnore]
        [Key]
        [Column("account_id")]
        [Required]
        public int AccountId { get; set; }
        [Column("holder_name")]
        [Required]
        public string HolderName { get; set; } = string.Empty;
        [Column("balance")]
        [Required]
        public float Balance { get; set; } = 0.0f; // Changed from double to float as an alternative

        [Column("account_status")]
        public string Status { get; set; } = "INACTIVE";

        [Column("manager_id")]
        [JsonIgnore]
        [Required]
        public int ManagerId { get; set; }

        [ForeignKey("ManagerId")]
        public Manager Manager { get; set; }

        [JsonPropertyName("region")]
        [Column("region")]
        [Required]
        public string AccountRegion { get; set; } = string.Empty;
    }
}