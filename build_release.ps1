$root = $PSScriptRoot
$version = "1.0.0"
$outputZip = Join-Path $root "StringToRedstoneSlab-v$version.zip"

if (Test-Path $outputZip) {
    Remove-Item $outputZip -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$itemsToInclude = @(
    "assets",
    "pack.mcmeta",
    "pack.png",
    "LICENSE",
    "credits.txt",
    "respackopts.json5"
)

$zipStream = [System.IO.File]::Open($outputZip, [System.IO.FileMode]::CreateNew)
$archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)

foreach ($item in $itemsToInclude) {
    $fullPath = Join-Path $root $item
    if (Test-Path $fullPath) {
        if ((Get-Item $fullPath).PSIsContainer) {
            Get-ChildItem -Path $fullPath -Recurse -File | ForEach-Object {
                $relative = $_.FullName.Substring($root.Length + 1).Replace("\", "/")
                $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
                $entryStream = $entry.Open()
                $fileStream = [System.IO.File]::OpenRead($_.FullName)
                $fileStream.CopyTo($entryStream)
                $fileStream.Dispose()
                $entryStream.Dispose()
            }
        } else {
            $relative = $item.Replace("\", "/")
            $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
            $entryStream = $entry.Open()
            $fileStream = [System.IO.File]::OpenRead($fullPath)
            $fileStream.CopyTo($entryStream)
            $fileStream.Dispose()
            $entryStream.Dispose()
        }
    }
}

$archive.Dispose()
$zipStream.Dispose()

Write-Host "Created release package with standardized paths: $outputZip"
