$ErrorActionPreference = 'Stop'

$Source = Join-Path $PSScriptRoot 'phpinfo.php'
$Destination = 'C:\Apache\htdocs'

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
    throw "Source file not found: $Source"
}

New-Item -ItemType Directory -Path $Destination -Force | Out-Null
Copy-Item -LiteralPath $Source -Destination $Destination -Force
