
[CmdletBinding()]
param (
    [Parameter(Mandatory, Position=0)]
    [System.IO.DirectoryInfo] $FStarRootPath,
    [Alias("pi")][switch] $PrintImplicits,
    [Alias("pfn")][switch] $PrintFullNames,
    [Alias("dirs")][System.IO.DirectoryInfo[]] $ExtraIncludeDirs = @(),
    [string] $Prefix = "",
    [Alias("odir")][System.IO.DirectoryInfo] $OutDirectoryPath = $null
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

if (-not $FStarRootPath.Exists) {
    throw "Directory is not exists. (FStarRootPath = $FStarRootPath)"
}

#--- Ensure OutDirectoryPath ---
if ($null -eq $OutDirectoryPath) {
    $OutDirectoryPath = [System.IO.DirectoryInfo]::new("$PSScriptRoot/../")
}

if (-not $OutDirectoryPath.Exists) {
    throw "Directory is not exists. (OutDirectoryPath = $OutDirectoryPath)"
}
#---|

$fstarFileName = $IsWindows ? "fstar.exe" : "fstar"
$fstarFilePath = Join-Path $FStarRootPath bin $fstarFileName -Resolve
$fstarLibPath = Join-Path $FStarRootPath lib fstar ulib -Resolve

$options = @("--cache_dir", ".cache.boot", "--no_location_info", "--warn_error", "-271-272-241-319-274")
if ($PrintImplicits) { $options += "--print_implicits" }
if ($PrintFullNames) { $options += "--print_full_names" }

$extraIncludeDirFullNames = $ExtraIncludeDirs | ForEach-Object { $_.FullName }
$includeDirs = @($fstarLibPath) + $extraIncludeDirFullNames + $OutDirectoryPath.FullName

$resultConfig = @{
    fstar_exe = $fstarFilePath
    options = $options
    include_dirs = $includeDirs
}

$outFilePath = Join-Path $OutDirectoryPath "$Prefix.fst.config.json"
ConvertTo-Json $resultConfig | Out-File $outFilePath