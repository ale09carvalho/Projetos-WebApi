# Guia — CRUD de Usuários (Atividade 05)

Tutorial baseado no PDF `DesenvolvAPI_Ativ_CRUDusuarios.pdf`.

**Objetivo:** implementar o CRUD de usuários no projeto **Exo.WebApi**, criando/alterando os arquivos abaixo e testando no Insomnia.

---

## Pré-requisitos

1. **.NET 6 ou superior** — verifique com:

```bash
dotnet --version
```

2. **Banco de dados** — se precisar recriar o banco, execute o script `cria-db.sql` no SSMS (pasta `Material-Aluno` do ZIP da atividade). Se o banco já existir das atividades anteriores, pule essa etapa.

3. Abra o projeto no VS Code:

```bash
code .
```

---

## Arquivos a criar

| Arquivo | Pasta |
|---------|-------|
| `Usuario.cs` | `Models/` |
| `UsuariosController.cs` | `Controllers/` |
| `UsuarioRepository.cs` | `Repositories/` |

## Arquivos a alterar

| Arquivo | Alteração |
|---------|-----------|
| `Contexts/ExoContext.cs` | Adicionar `DbSet<Usuario>` |
| `Program.cs` | Registrar `UsuarioRepository` no DI |

---

## 1. `Models/Usuario.cs` (criar)

Crie o arquivo e substitua o conteúdo pelo código abaixo:

```csharp
namespace Exo.WebApi
{
    public class Usuario
    {
        public int Id { get; set; }
        public string Email { get; set; }
        public string Senha { get; set; }
    }
}
```

---

## 2. `Controllers/UsuariosController.cs` (criar)

Crie o arquivo e insira o código completo:

```csharp
using Exo.WebApi.Models;
using Exo.WebApi.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;

namespace Exo.WebApi.Controllers
{
    [Produces("application/json")]
    [Route("api/[controller]")]
    [ApiController]
    public class UsuariosController : ControllerBase
    {
        private readonly UsuarioRepository _usuarioRepository;

        public UsuariosController(UsuarioRepository usuarioRepository)
        {
            _usuarioRepository = usuarioRepository;
        }

        // get -> /api/usuarios
        [HttpGet]
        public IActionResult Listar()
        {
            return Ok(_usuarioRepository.Listar());
        }

        // post -> /api/usuarios
        [HttpPost]
        public IActionResult Cadastrar(Usuario usuario)
        {
            _usuarioRepository.Cadastrar(usuario);
            return StatusCode(201);
        }

        // get -> /api/usuarios/{id}
        [HttpGet("{id}")] // Faz a busca pelo ID.
        public IActionResult BuscarPorId(int id)
        {
            Usuario usuario = _usuarioRepository.BuscaPorId(id);

            if (usuario == null)
            {
                return NotFound();
            }

            return Ok(usuario);
        }

        // put -> /api/usuarios/{id}
        // Atualiza.
        [HttpPut("{id}")]
        public IActionResult Atualizar(int id, Usuario usuario)
        {
            _usuarioRepository.Atualizar(id, usuario);
            return StatusCode(204);
        }

        // delete -> /api/usuarios/{id}
        [HttpDelete("{id}")]
        public IActionResult Deletar(int id)
        {
            try
            {
                _usuarioRepository.Deletar(id);
                return StatusCode(204);
            }
            catch (Exception e)
            {
                return BadRequest();
            }
        }
    }
}
```

### Endpoints do controller

| Método HTTP | Rota | Ação | Resposta |
|-------------|------|------|----------|
| `GET` | `/api/usuarios` | Listar todos | `200 OK` |
| `POST` | `/api/usuarios` | Cadastrar | `201 Created` |
| `GET` | `/api/usuarios/{id}` | Buscar por ID | `200 OK` ou `404 Not Found` |
| `PUT` | `/api/usuarios/{id}` | Atualizar | `204 No Content` |
| `DELETE` | `/api/usuarios/{id}` | Deletar | `204 No Content` ou `400 Bad Request` |

---

## 3. `Repositories/UsuarioRepository.cs` (criar)

Crie o arquivo e insira o código completo:

```csharp
using Exo.WebApi.Contexts;
using Exo.WebApi.Models;
using System.Collections.Generic;
using System.Linq;

namespace Exo.WebApi.Repositories
{
    public class UsuarioRepository
    {
        private readonly ExoContext _context;

        public UsuarioRepository(ExoContext context)
        {
            _context = context;
        }

        public Usuario Login(string email, string senha)
        {
            return _context.Usuarios.FirstOrDefault(u => u.Email == email && u.Senha == senha);
        }

        public List<Usuario> Listar()
        {
            return _context.Usuarios.ToList();
        }

        public void Cadastrar(Usuario usuario)
        {
            _context.Usuarios.Add(usuario);
            _context.SaveChanges();
        }

        public Usuario BuscaPorId(int id)
        {
            return _context.Usuarios.Find(id);
        }

        public void Atualizar(int id, Usuario usuario)
        {
            Usuario usuarioBuscado = _context.Usuarios.Find(id);

            if (usuarioBuscado != null)
            {
                usuarioBuscado.Email = usuario.Email;
                usuarioBuscado.Senha = usuario.Senha;
            }

            _context.Usuarios.Update(usuarioBuscado);
            _context.SaveChanges();
        }

        public void Deletar(int id)
        {
            Usuario usuarioBuscado = _context.Usuarios.Find(id);
            _context.Usuarios.Remove(usuarioBuscado);
            _context.SaveChanges();
        }
    }
}
```

> **Nota do PDF:** além dos métodos do CRUD e o `BuscaPorId()`, a classe inclui o método `Login`, que será utilizado na última atividade do projeto.

---

## 4. `Contexts/ExoContext.cs` (alterar)

Inclua a linha abaixo **no lugar indicado** (junto aos demais `DbSet`):

```csharp
public DbSet<Usuario> Usuarios { get; set; }
```

Exemplo de como o arquivo deve ficar:

```csharp
using Exo.WebApi.Models;
using Microsoft.EntityFrameworkCore;
using System.Data.SqlClient;
using Microsoft.Data.SqlClient;

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
            // A conexão é configurada no Program.cs via appsettings.Development.json
        }

        public DbSet<Projeto> Projetos { get; set; }
        public DbSet<Usuario> Usuarios { get; set; }
    }
}
```

---

## 5. `Program.cs` (alterar)

Inclua a linha abaixo **no lugar indicado** (junto aos demais serviços `AddTransient`):

```csharp
builder.Services.AddTransient<UsuarioRepository, UsuarioRepository>();
```

Exemplo de como o arquivo deve ficar:

```csharp
using Exo.WebApi.Contexts;
using Exo.WebApi.Repositories;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<ExoContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("ExoApi")));
builder.Services.AddControllers();
builder.Services.AddTransient<ProjetoRepository, ProjetoRepository>();
builder.Services.AddTransient<UsuarioRepository, UsuarioRepository>();

var app = builder.Build();

app.UseRouting();

app.UseEndpoints(endpoints =>
{
    endpoints.MapControllers();
});

app.Run();
```

---

## 6. Compilar e executar

No terminal do VS Code:

```bash
dotnet restore
dotnet build
dotnet run
```

Anote o endereço exibido no terminal (ex.: `https://localhost:7154`). Os testes usam o sufixo `api/usuarios`.

---

## 7. Testes no Insomnia

Baixe o Insomnia em: https://insomnia.rest/download

Substitua `https://localhost:7154` pela URL que aparecer no seu terminal, se for diferente.

### 7.1 Listar — `GET`

- **Método:** `GET`
- **URL:** `https://localhost:7154/api/usuarios`
- **Resposta esperada:** `200 OK` com a lista de usuários

### 7.2 Cadastrar — `POST`

- **Método:** `POST`
- **URL:** `https://localhost:7154/api/usuarios/`
- **Body:** JSON

```json
{
    "email": "email_tres@sp.br",
    "senha": "1234"
}
```

- **Resposta esperada:** `201 Created`

> O campo `id` não é enviado — ele é autoincremento no banco.

### 7.3 Buscar por ID — `GET`

- **Método:** `GET`
- **URL:** `https://localhost:7154/api/usuarios/3`
- **Resposta esperada:** `200 OK` com o usuário de id 3

### 7.4 Atualizar — `PUT`

- **Método:** `PUT`
- **URL:** `https://localhost:7154/api/usuarios/3`
- **Body:** JSON

```json
{
    "email": "email_quatro@sp.br",
    "senha": "4321"
}
```

- **Resposta esperada:** `204 No Content`

> O `3` na URL é o id do registro a atualizar — use outro id conforme seu banco.

### 7.5 Deletar — `DELETE`

- **Método:** `DELETE`
- **URL:** `https://localhost:7154/api/usuarios/3`
- **Resposta esperada:** `204 No Content`

### 7.6 Confirmar exclusão — `GET`

- **Método:** `GET`
- **URL:** `https://localhost:7154/api/usuarios/`
- **Resposta esperada:** lista sem o usuário deletado

---

## Checklist final

- [ ] `Models/Usuario.cs` criado
- [ ] `Controllers/UsuariosController.cs` criado
- [ ] `Repositories/UsuarioRepository.cs` criado
- [ ] `DbSet<Usuario>` adicionado em `ExoContext.cs`
- [ ] `UsuarioRepository` registrado em `Program.cs`
- [ ] `dotnet restore` executado sem erros
- [ ] `dotnet build` executado sem erros
- [ ] `dotnet run` iniciou a API
- [ ] Testes GET, POST, PUT e DELETE no Insomnia concluídos
