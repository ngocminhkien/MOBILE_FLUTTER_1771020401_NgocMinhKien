using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PcmApi.Models;

namespace PcmApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<Member> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;

        public AuthController(UserManager<Member> userManager, RoleManager<IdentityRole> roleManager)
        {
            _userManager = userManager;
            _roleManager = roleManager;
        }

        // --- ĐĂNG KÝ ---
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterModel model)
        {
            if (!await _roleManager.RoleExistsAsync("Admin")) await _roleManager.CreateAsync(new IdentityRole("Admin"));
            if (!await _roleManager.RoleExistsAsync("Member")) await _roleManager.CreateAsync(new IdentityRole("Member"));

            var user = new Member 
            { 
                UserName = model.Email, 
                Email = model.Email, 
                FullName = model.FullName,
                WalletBalance = 0 
            };
            
            var result = await _userManager.CreateAsync(user, model.Password);

            if (result.Succeeded)
            {
                if (model.Email.ToLower().Contains("admin"))
                    await _userManager.AddToRoleAsync(user, "Admin");
                else
                    await _userManager.AddToRoleAsync(user, "Member");

                return Ok("Đăng ký thành công!");
            }
            return BadRequest(result.Errors);
        }

        // --- ĐĂNG NHẬP (SỬA ĐỂ TRẢ VỀ SỐ DƯ) ---
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user != null && await _userManager.CheckPasswordAsync(user, model.Password))
            {
                var roles = await _userManager.GetRolesAsync(user);
                var role = roles.FirstOrDefault() ?? "Member";

                return Ok(new { 
                    message = "Đăng nhập thành công!", 
                    userId = user.Id,
                    fullName = user.FullName,
                    email = user.Email,
                    role = role,
                    walletBalance = user.WalletBalance // <--- QUAN TRỌNG: Trả về số dư
                });
            }
            return Unauthorized("Sai email hoặc mật khẩu!");
        }

        // --- NẠP TIỀN (SỬA ĐỂ LƯU VÀO DATABASE) ---
        [HttpPost("topup")]
        public async Task<IActionResult> TopUp(string email, decimal amount)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null) return NotFound("Không tìm thấy người dùng");
            
            user.WalletBalance += amount; 
            
            var result = await _userManager.UpdateAsync(user); // <--- QUAN TRỌNG: Lưu thay đổi
            
            if(result.Succeeded)
                return Ok(new { newBalance = user.WalletBalance });
            else
                return BadRequest("Lỗi khi lưu vào cơ sở dữ liệu");
        }
        
        // --- API LẤY DANH SÁCH THÀNH VIÊN ---
        [HttpGet("members")]
        public async Task<ActionResult<IEnumerable<dynamic>>> GetMembers()
        {
            var users = _userManager.Users.Select(u => new {
                u.FullName,
                u.Email,
                tier = u.WalletBalance > 1000000 ? "Gold" : "Member" // Ví dụ phân hạng
            }).ToList();
            return Ok(users);
        }
    }

    public class LoginModel {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
    public class RegisterModel {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
    }
}