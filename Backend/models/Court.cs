using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PcmApi.Models
{
    [Table("Courts")] 
    public class Court
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;

        [Column(TypeName = "decimal(18, 2)")]
        public decimal PricePerHour { get; set; }
    }
}