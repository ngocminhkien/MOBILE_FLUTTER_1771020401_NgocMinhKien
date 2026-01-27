using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Identity;

namespace PcmApi.Models
{
    public class Member : IdentityUser
    {
        public string FullName { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        
        [Column(TypeName = "decimal(18, 2)")]
        public decimal WalletBalance { get; set; } = 0;

        public string Tier { get; set; } = "Standard";
        public double RankLevel { get; set; } = 0;
    }
}