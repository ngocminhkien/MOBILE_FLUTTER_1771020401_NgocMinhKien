using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PcmApi.Data;
using PcmApi.Models;

namespace PcmApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TournamentsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public TournamentsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Tournament>>> GetTournaments()
        {
            return await _context.Tournaments.OrderByDescending(t => t.StartDate).ToListAsync();
        }

        // SỬA HÀM NÀY ĐỂ TẠO GIẢI ĐẤU THÀNH CÔNG
        [HttpPost]
        public async Task<ActionResult<Tournament>> PostTournament(Tournament tournament)
        {
            // Kiểm tra dữ liệu hợp lệ
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Đặt giá trị mặc định nếu client không gửi
            if (tournament.StartDate == default) tournament.StartDate = DateTime.Now.AddDays(7); // Mặc định 1 tuần sau
            if (string.IsNullOrEmpty(tournament.Status)) tournament.Status = "Upcoming";

            _context.Tournaments.Add(tournament);
            await _context.SaveChangesAsync();

            // Trả về 201 Created cùng với dữ liệu vừa tạo
            return CreatedAtAction("GetTournaments", new { id = tournament.Id }, tournament);
        }
    }
}