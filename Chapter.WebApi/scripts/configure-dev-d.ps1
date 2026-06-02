# Redireciona caches de desenvolvimento .NET/NuGet para D:\DevCache
# Execute uma vez: powershell -ExecutionPolicy Bypass -File scripts\configure-dev-d.ps1

$base = "D:\DevCache"
$dirs = @(
    "$base\nuget-packages",
    "$base\nuget-http-cache",
    "$base\dotnet-cli",
    "$base\docker-nuget",
    "$base\build"
)

foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

$vars = @{
    NUGET_PACKAGES           = "$base\nuget-packages"
    NUGET_HTTP_CACHE_PATH    = "$base\nuget-http-cache"
    DOTNET_CLI_HOME          = "$base\dotnet-cli"
}

foreach ($kv in $vars.GetEnumerator()) {
    [Environment]::SetEnvironmentVariable($kv.Key, $kv.Value, "User")
    Set-Item -Path "env:$($kv.Key)" -Value $kv.Value
    Write-Host "OK $($kv.Key) = $($kv.Value)"
}

Write-Host ""
Write-Host "Variaveis gravadas no perfil do usuario. Feche e reabra o Cursor/terminal."
Write-Host "Docker: Settings > Resources > Advanced > Disk image location = D:\DevCache\docker-data"
Write-Host ""
Write-Host "Opcional - liberar espaco em C: (cache antigo NuGet):"
Write-Host "  Remove-Item -Recurse -Force `$env:USERPROFILE\.nuget\packages -ErrorAction SilentlyContinue"
