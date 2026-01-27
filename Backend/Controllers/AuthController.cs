using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PcmApi.Models;

namespace PcmApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController] // Dòng này rất quan trọng để Swagger nhận diện
    public class AuthController : ControllerBase
    {
        private readonly UserManager<Member> _userManager;

        public AuthController(UserManager<Member> userManager)
        {
            _userManager = userManager;
        }
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user != null && await _userManager.CheckPasswordAsync(user, model.Password))
            {
                return Ok(new { 
                    message = "Dang nhap thanh cong!", 
                    fullName = user.FullName,
                    userId = user.Id 
                });
            }
            return Unauthorized("Sai email hoac mat khau!");
        }

public class LoginModel {
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterModel model)
        {
            var user = new Member 
            { 
                UserName = model.Email, 
                Email = model.Email, 
                FullName = model.FullName 
            };
            
            var result = await _userManager.CreateAsync(user, model.Password);

            if (result.Succeeded) return Ok("Dang ky thanh cong!");
            return BadRequest(result.Errors);
        }
        [HttpPost("topup")]
        public async Task<IActionResult> TopUp(string email, decimal amount)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null) return NotFound("Khong tim thay nguoi dung");

            user.WalletBalance += amount; // Cộng tiền vào ví
            var result = await _userManager.UpdateAsync(user);

            if (result.Succeeded) return Ok($"Nap thanh cong! So du hien tai: {user.WalletBalance}");
            return BadRequest("Loi khi nap tien");
        }
    }
    

    public class RegisterModel
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
    }
}