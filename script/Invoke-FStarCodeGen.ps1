using namespace System.IO

[CmdletBinding()]
param (
    [Parameter(Mandatory)][FileInfo] $FStar,
    [Parameter(Mandatory)][string[]] $Path,
    [Parameter(Mandatory)][DirectoryInfo] $Out,
    [ValidateSet("OCaml", "FSharp")][string] $Kind = "FSharp",
    [Alias("lq")][switch] $LogQueries,
    [string[]] $ArgumentList = @()
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

if (-not ($Out.Exists)) {
    throw "Directory is not exist. (Out = $Out)"
}

$ensuredFiles = $Path | Where-Object { $_.EndsWith(".fst") -and [File]::Exists($_) }
$ensuredDirectories = $Path | Where-Object { [Directory]::Exists($_) }

$files = @() + $ensuredFiles
foreach ($dir in $ensuredDirectories) {
    $resolved = Join-Path $dir "*.fst" -Resolve
    $files = $files + $resolved

    $resolved = Join-Path $dir "*.fsti" -Resolve
    $files = $files + $resolved
}

$files | Select-Object @{l="File"; e={$_}} | Out-String | Write-Host 

$options = @()
if ($LogQueries) { $options += "--log_queries" }

& $FStar --codegen $Kind --odir $Out @options @ArgumentList @files 
