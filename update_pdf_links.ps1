$ErrorActionPreference = 'Stop'
try {
    $root = $PSScriptRoot
    $pdfRoot = Join-Path $root 'pdf'
    if (-not (Test-Path -LiteralPath $pdfRoot -PathType Container)) { throw 'Put these updater files next to index.html and the pdf folder.' }
    $files = @(Get-ChildItem -LiteralPath $pdfRoot -Recurse -File | Where-Object { $_.Extension -ieq '.pdf' })
    $paths = @($files | ForEach-Object { $_.FullName.Substring($root.Length + 1).Replace('\','/') } | Sort-Object)
    $matched = @{}
    foreach ($n in 14..17) {
        $candidates = @($paths | Where-Object {
            if ($_ -notlike 'pdf/sebang/msds/*') { return $false }
            $name = ($_ -split '/')[-1]
            if ($name -match '^\s*\(?\s*(\d+(?:\s*[,、]\s*\d+)*)') {
                return @(($Matches[1] -split '[,、]') | ForEach-Object { [int]$_.Trim() }) -contains $n
            }
            return $false
        })
        if ($candidates.Count -ne 1) { throw ('Sebang ' + $n + ': found ' + $candidates.Count + ' matching PDFs. Filename must start with its item number, with one file per item.') }
        $matched[$n] = $candidates[0]
    }
    $json = ConvertTo-Json -InputObject $paths -Compress
    $content = 'window.PDF_INVENTORY = ' + $json + ';'
    [IO.File]::WriteAllText((Join-Path $root 'pdf_inventory.js'), $content, (New-Object Text.UTF8Encoding($false)))
    Write-Host 'Success: pdf_inventory.js updated. Sebang 14-17 linked from real filenames.'
    foreach ($n in 14..17) { Write-Host ($n.ToString() + ' -> ' + $matched[$n]) }
    Write-Host 'Commit and Push index.html, pdf_inventory.js, and your PDF files together.'
} catch {
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
