using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace GlobalAccountsService.Models
{
    [Table("manager")]
    public class Manager
    {
        [JsonPropertyName("id")]
        [Key]
        [Column("manager_id")]
        [Required]
        public int ManagerId { get; set; }
        [Column("name")]
        [Required]
        public string Name { get; set; }
    }
}