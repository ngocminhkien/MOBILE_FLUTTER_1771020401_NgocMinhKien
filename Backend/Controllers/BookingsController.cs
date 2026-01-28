using Microsoft.AspNetCore.Identity;
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
        private readonly UserManager<Member> _userManager;

        // Hàm khởi tạo để nạp Database và UserManager
        public BookingsController(ApplicationDbContext context, UserManager<Member> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        [HttpGet("member/{memberId}")]
        public async Task<ActionResult<IEnumerable<Booking>>> GetMemberBookings(string memberId)
        {
            return await _context.Bookings
                .Where(b => b.MemberId == memberId)
                .OrderByDescending(b => b.StartTime)
                .ToListAsync();
        }

        [HttpPost]
        public async Task<ActionResult<Booking>> PostBooking(Booking booking)
        {
            // 1. Kiểm tra Sân có tồn tại không và lấy giá tiền thực tế
            var court = await _context.Courts.FindAsync(booking.CourtId);
            if (court == null) return NotFound(new { message = "Không tìm thấy sân này!" });

            // 2. Tự động tính EndTime (mặc định 1 tiếng nếu client không gửi)
            if (booking.EndTime <= booking.StartTime)
            {
                booking.EndTime = booking.StartTime.AddHours(1);
            }

            // 3. KIỂM TRA TRÙNG LỊCH (Chặn nếu thời gian bắt đầu nằm trong khoảng của đơn khác)
            bool isOccupied = await _context.Bookings.AnyAsync(b => 
                b.CourtId == booking.CourtId && 
                b.Status != "Cancelled" &&
                ((booking.StartTime >= b.StartTime && booking.StartTime < b.EndTime) ||
                 (booking.EndTime > b.StartTime && booking.EndTime <= b.EndTime)));

            if (isOccupied)
            {
                return BadRequest(new { message = "Sân đã có người đặt trong khoảng thời gian này!" });
            }

            // 4. KIỂM TRA NGƯỜI DÙNG VÀ SỐ DƯ VÍ
            var user = await _userManager.FindByIdAsync(booking.MemberId);
            if (user == null) return NotFound(new { message = "Không tìm thấy người dùng." });

            // Tính tổng tiền dựa trên giá sân
            booking.TotalPrice = court.PricePerHour; 

            if (user.WalletBalance < booking.TotalPrice)
            {
                return BadRequest(new { message = "Số dư ví không đủ! Vui lòng nạp thêm tiền." });
            }

            // 5. TRỪ TIỀN VÀ LƯU DỮ LIỆU
            user.WalletBalance -= booking.TotalPrice;
            var updateResult = await _userManager.UpdateAsync(user);

            if (!updateResult.Succeeded) 
                return BadRequest(new { message = "Lỗi khi cập nhật số dư ví." });

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return Ok(booking);
        }

        [HttpGet("slots")]
        public async Task<ActionResult<IEnumerable<string>>> GetBookedSlots(DateTime date)
        {
            var booked = await _context.Bookings
                .Where(b => b.StartTime.Date == date.Date && b.Status != "Cancelled")
                .Select(b => b.StartTime.ToString("HH:mm"))
                .ToListAsync();
            return Ok(booked);
        }
    }
}