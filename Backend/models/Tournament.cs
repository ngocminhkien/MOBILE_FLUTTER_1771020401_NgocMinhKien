using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PcmApi.Models
{
    [Table("Tournaments")]
    public class Tournament
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Tên giải đấu là bắt buộc")]
        public string Name { get; set; } = string.Empty;

        public DateTime StartDate { get; set; }

        public string Status { get; set; } = "Upcoming"; // Upcoming, Ongoing, Finished
        public String Format{get;set;} ="2v2";
        // Thêm trường tiền thưởng
        [Column(TypeName = "decimal(18, 2)")]
        public decimal PrizeMoney { get; set; } = 0;
    }
}