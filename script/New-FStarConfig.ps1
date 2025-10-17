
[CmdletBinding()]
param (
    [Parameter(Mandatory, Position=0)]
    [System.IO.DirectoryInfo] $FStarRootPath
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

if (-not $FStarRootPath.Exists) {
    throw "Directory is not exists. ($FStarRootPath)"
}

$fstarFileName = $IsWindows ? "fstar.exe" : "fstar"
$fstarFilePath = Join-Path $FStarRootPath bin $fstarFileName -Resolve
$fstarLibPath = Join-Path $FStarRootPath lib fstar ulib -Resolve

$resultConfig = @{
    fstar_exe = $fstarFilePath
    options = @("--cache_dir", ".cache.boot", "--no_location_info", "--warn_error", "-271-272-241-319-274")
    include_dirs = @($fstarLibPath)
}

ConvertTo-Json $resultConfig | Out-File "$PSScriptRoot/../.fst.config.json"