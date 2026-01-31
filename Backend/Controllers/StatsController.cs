using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PcmApi.Data;

namespace PcmApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StatsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public StatsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboardStats()
        {
            // Đếm số lượng từ Database
            var totalMembers = await _context.Users.CountAsync();
            var totalTournaments = await _context.Tournaments.CountAsync();
            
            // QUAN TRỌNG: Đếm giải đấu có Status là "Pending"
            var pendingTournaments = await _context.Tournaments.CountAsync(t => t.Status == "Pending");
            
            // Tính tổng tiền
            var totalWallet = await _context.Users.SumAsync(u => u.WalletBalance);

            // Trả về JSON đúng tên khớp với Frontend
            return Ok(new
            {
                members = totalMembers,
                tournaments = totalTournaments,
                pendingRequests = pendingTournaments,
                systemBalance = totalWallet
            });
        }
    }
}