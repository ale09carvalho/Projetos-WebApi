param(
    [Parameter(Mandatory = $true)]
    [string[]]$DotnetArgs
)

$projectRoot = Split-Path $PSScriptRoot -Parent
$devCache = "D:\DevCache"

@(
    "$devCache\nuget-packages",
    "$devCache\docker-nuget",
    "$devCache\build"
) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

$dotnetCmd = @("dotnet") + $DotnetArgs
$dotnetCmdStr = $dotnetCmd -join " "

docker run --rm `
    -v "${projectRoot}:/src" `
    -v "${devCache}\nuget-packages:/root/.nuget/packages" `
    -v "${devCache}\docker-nuget:/root/.nuget" `
    -w /src `
    mcr.microsoft.com/dotnet/sdk:6.0 `
    bash -c $dotnetCmdStr
