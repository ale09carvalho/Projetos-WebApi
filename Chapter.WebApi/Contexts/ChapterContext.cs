using Chapter.WebApi.Models;
using Microsoft.EntityFrameworkCore;

namespace Chapter.WebApi.Contexts
{
    public class ChapterContext : DbContext
    {
        public ChapterContext()
        {
        }

        public ChapterContext(DbContextOptions<ChapterContext> options) : base(options)
        {
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                // Fallback quando DI não injeta options (conforme material SENAI).
                optionsBuilder.UseSqlServer(
                    "Server=localhost,1433;Database=Chapter;User Id=sa;Password=@Admin123;TrustServerCertificate=True;");
            }
        }

        public DbSet<Livro> Livros { get; set; }
    }
}
