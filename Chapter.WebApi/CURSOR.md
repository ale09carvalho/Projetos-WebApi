# Chapter.WebApi — Guia Cursor + Docker (.NET 6)

Material SENAI adaptado para **Cursor** e para o ambiente Docker (`dotnet/sdk:6.0` + SQL Server na porta `1433`).

## Economizar espaço em C: (usar unidade D:)

O projeto já fica em `D:\Sistemas\Chapter.WebApi`. Caches foram redirecionados para `D:\DevCache`:

| O quê | Onde (D:) |
|-------|-----------|
| Pacotes NuGet | `D:\DevCache\nuget-packages` (variável `NUGET_PACKAGES`) |
| Cache HTTP NuGet | `D:\DevCache\nuget-http-cache` |
| Ferramentas `dotnet tool` | `D:\DevCache\dotnet-cli` |
| Build `bin/obj` (Windows) | `D:\DevCache\build\Chapter.WebApi\` |

**Configurar uma vez** (feche e reabra o terminal depois):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\configure-dev-d.ps1
```

**Docker** (imagens/containers): em *Docker Desktop → Settings → Resources → Advanced → Disk image location*, defina `D:\DevCache\docker-data`.

**Build com .NET 6 no Docker** (NuGet em D:):

```powershell
.\scripts\docker-dotnet.ps1 restore
.\scripts\docker-dotnet.ps1 build
```

Ou manualmente:

```powershell
docker run --rm -v "d:\Sistemas\Chapter.WebApi:/src" -v "D:\DevCache\nuget-packages:/root/.nuget/packages" -w /src mcr.microsoft.com/dotnet/sdk:6.0 dotnet build
```

## Pré-requisitos

- Docker com container SQL Server (`sqlserver`) na porta **1433**
- Senha SA: `@Admin123` (igual ao seu container atual)
- Opcional no Windows: [.NET 6 SDK](https://dotnet.microsoft.com/download/dotnet/6.0) para `dotnet run` local

## Pacotes (equivalente ao PDF, versão 6.x)

Instalados no `Chapter.WebApi.csproj`:

| PDF (6.0.0) | Projeto |
|-------------|---------|
| Microsoft.VisualStudio.Web.CodeGeneration.Design | 6.0.18 |
| Microsoft.EntityFrameworkCore | 6.0.36 |
| Microsoft.EntityFrameworkCore.SqlServer | 6.0.36 |
| Microsoft.AspNetCore.Authentication.JwtBearer | 6.0.36 |
| Microsoft.EntityFrameworkCore.Tools.DotNet | → `Microsoft.EntityFrameworkCore.Tools` 6.0.36 |

## Cursor — instalar pacote (em vez do NuGet Package Manager)

Terminal integrado (`Ctrl+`` `):

```bash
dotnet add package NomeDoPacote --version 6.0.36
```

## Scaffolding (controlador vazio)

```bash
dotnet tool install --global dotnet-aspnet-codegenerator --version 6
dotnet aspnet-codegenerator controller -name LivrosController -api -outDir Controllers
```

O controlador já está criado com o CRUD completo do PDF.

## Banco de dados

Script: `docker/init-db.sql` (baseado no `db.sql` do curso).

Com SQL Server já rodando no Docker:

```bash
docker cp docker/init-db.sql sqlserver:/tmp/init-db.sql
docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "@Admin123" -C -i /tmp/init-db.sql
```

Se `sqlcmd` não existir no container, execute o script no **Azure Data Studio** ou **SSMS** conectando em `localhost,1433`.

## Executar a API

### Opção A — Docker (.NET 6, igual à imagem `dotnet/sdk:6.0`)

```bash
docker build -t chapter-webapi .
docker run --rm -p 7028:8080 -e "ConnectionStrings__Chapter=Server=host.docker.internal,1433;Database=Chapter;User Id=sa;Password=@Admin123;TrustServerCertificate=True;" chapter-webapi
```

### Opção B — Máquina local (requer SDK 6+ instalado)

```bash
dotnet restore
dotnet build
dotnet run
```

URL de teste: **http://localhost:7028/api/livros**

## Testes (Insomnia / arquivo .http)

- GET `http://localhost:7028/api/livros`
- GET `http://localhost:7028/api/livros/2`
- PUT/POST/DELETE conforme o PDF

Use o arquivo `Chapter.WebApi.http` no Cursor (REST Client).

## Estrutura do projeto

```
Controllers/LivrosController.cs
Models/Livro.cs
Repositories/LivroRepository.cs
Contexts/ChapterContext.cs
Program.cs
```

## Diferenças em relação ao PDF

| PDF | Esta adaptação |
|-----|----------------|
| VS Code + NuGet Package Manager | Cursor + `dotnet add package` |
| .NET 6.0.0 fixo nos pacotes | 6.0.36 (patch mais recente da linha 6) |
| `net10` / Minimal API weather | `net6.0` + MVC Controllers |
| String fixa `SQLEXPRESS` | SQL Server Docker `localhost,1433` + `appsettings.json` |
| `UseEndpoints` | `MapControllers()` (.NET 6) |
