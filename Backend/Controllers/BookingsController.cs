using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PcmApi.Data;
using PcmApi.Models;

namespace PcmApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookingsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public BookingsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<ActionResult<Booking>> PostBooking(Booking booking)
        {
            // Kiểm tra sân có tồn tại không
            var court = await _context.Courts.FindAsync(booking.CourtId);
            if (court == null) return NotFound("Khong tim thay san!");

            // Tính tổng tiền tự động dựa trên giá sân (giả sử đặt theo giờ)
            var duration = (booking.EndTime - booking.StartTime).TotalHours;
            booking.TotalPrice = (decimal)duration * court.PricePerHour;

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();
            return Ok(booking);
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Booking>>> GetBookings()
        {
            return await _context.Bookings.Include(b => b.Court).Include(b => b.Member).ToListAsync();
        }
    }
}