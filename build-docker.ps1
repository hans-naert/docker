param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Dockerfile
)

$ErrorActionPreference = 'Stop'

$Filename = [System.IO.Path]::GetFileName($Dockerfile)
if ($Filename -notmatch '^.+\.Dockerfile$') {
    throw "Dockerfile must be named <tag>.Dockerfile: $Filename"
}
$Tag = $Filename.Substring(0, $Filename.Length - '.Dockerfile'.Length)

if (-not [System.IO.Path]::IsPathRooted($Dockerfile)) {
    $Dockerfile = Join-Path $PSScriptRoot $Dockerfile
}

if (-not (Test-Path -LiteralPath $Dockerfile -PathType Leaf)) {
    throw "Dockerfile not found: $Dockerfile"
}

docker build --file $Dockerfile --tag $Tag $PSScriptRoot
exit $LASTEXITCODE
