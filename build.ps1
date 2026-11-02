# Builds dist\ForeverGraphics-<version>.zip for uploading to CurseForge.
# The version comes from "## Version" in the .toc. The archive contains a
# single ForeverGraphics\ folder, as CurseForge and the game client expect.
# Keep this file ASCII-only: Windows PowerShell 5.1 reads BOM-less files as ANSI.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$root = $PSScriptRoot
$addon = "ForeverGraphics"
$src = Join-Path $root $addon
$toc = Join-Path $src "$addon.toc"

$version = (Select-String -Path $toc -Pattern '^## Version:\s*(\S+)').Matches[0].Groups[1].Value
if (-not $version) { throw "No '## Version' in $toc" }

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force $dist | Out-Null
$zipPath = Join-Path $dist "$addon-$version.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }

# Compress-Archive in PowerShell 5.1 writes "\" into entry names, which breaks
# extraction outside Windows, so build the archive by hand with "/"
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, "Create")
try {
    Get-ChildItem $src -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($src.Length + 1).Replace("\", "/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, "$addon/$rel") | Out-Null
    }
} finally {
    $zip.Dispose()
}

Write-Host "Built: $zipPath"
