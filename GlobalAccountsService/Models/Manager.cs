using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GlobalAccountsService.Models
{
    [Table("manager")]
    public class Manager
    {
        [Key]
        [Column("manager_id")]
        [Required]
        public int ManagerId { get; set; }
        [Column("name")]
        [Required]
        public string Name { get; set; }
    }
}