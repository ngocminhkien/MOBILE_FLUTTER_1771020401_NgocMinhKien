using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PcmApi.Models
{
    [Table("Bookings")]
    public class Booking
    {
        [Key]
        public int Id { get; set; }

        public int CourtId { get; set; }
        public Court? Court { get; set; }

        public string MemberId { get; set; }
        public Member? Member { get; set; }

        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }

        [Column(TypeName = "decimal(18, 2)")]
        public decimal TotalPrice { get; set; }

        public string Status { get; set; } = "Confirmed";
    }
}