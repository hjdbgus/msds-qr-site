$ErrorActionPreference = 'Stop'
try {
    $root = $PSScriptRoot
    if (-not (Test-Path -LiteralPath (Join-Path $root 'index.html'))) {
        throw 'Place this file beside index.html in your repository.'
    }
    $pdfRoot = Join-Path $root 'pdf'
    if (-not (Test-Path -LiteralPath $pdfRoot)) {
        throw 'The pdf folder is missing. Place this file in the repository root.'
    }
    $paths = @(Get-ChildItem -LiteralPath $pdfRoot -Filter '*.pdf' -File -Recurse | ForEach-Object {
        $_.FullName.Substring($root.Length + 1).Replace('\', '/')
    } | Sort-Object)
    $json = ConvertTo-Json -InputObject $paths -Compress
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $root 'pdf_inventory.js'), ('window.PDF_INVENTORY = ' + $json + ';'), $utf8)
    Write-Host ('Updated pdf_inventory.js : ' + $paths.Count + ' PDF files.') -ForegroundColor Green
    Write-Host 'Commit index.html, pdf_inventory.js and the added PDF files, then Push origin.'
    Write-Host 'No PDF files were deleted, renamed or moved.'
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
