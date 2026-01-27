using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PcmApi.Data;
using PcmApi.Models;

namespace PcmApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourtsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CourtsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Court>>> GetCourts()
        {
            return await _context.Courts.ToListAsync();
        }

        [HttpPost]
        public async Task<ActionResult<Court>> PostCourt(Court court)
        {
            _context.Courts.Add(court);
            await _context.SaveChangesAsync();
            return Ok(court);
        }
    }
}