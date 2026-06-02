using Chapter.WebApi.Contexts;
using Chapter.WebApi.Repositories;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("Chapter")
    ?? "Server=localhost,1433;Database=Chapter;User Id=sa;Password=@Admin123;TrustServerCertificate=True;";

builder.Services.AddDbContext<ChapterContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddTransient<LivroRepository, LivroRepository>();

var app = builder.Build();

app.UseRouting();
app.UseHttpsRedirection();
app.MapControllers();

app.Run();
