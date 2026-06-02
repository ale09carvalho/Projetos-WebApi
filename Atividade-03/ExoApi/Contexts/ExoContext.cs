using Exo.WebApi.Models;
using Microsoft.EntityFrameworkCore;

namespace Exo.WebApi.Contexts
{
    public class ExoContext : DbContext
    {
        public ExoContext()
        {
        }

        public ExoContext(DbContextOptions<ExoContext> options) : base(options)
        {
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                // SQL Server no Docker (porta 1433) — mesmo ambiente do SSMS com usuário sa.
                optionsBuilder.UseSqlServer(
                    "Server=localhost,1433;Database=ExoApi;User Id=sa;Password=@Admin123;TrustServerCertificate=True;");
            }
        }

        public DbSet<Projeto> Projetos { get; set; }
    }
}
