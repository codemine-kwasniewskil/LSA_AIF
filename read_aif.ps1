param([string]$IfName = 'O_0027_002', [string]$NS = 'FREMDV')

Add-Type -AssemblyName System.IO.Compression.FileSystem

function ReadXlsx($path) {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($path)
    $ssEntry = $zip.Entries | Where-Object { $_.FullName -eq 'xl/sharedStrings.xml' }
    $strings = @()
    if ($ssEntry) {
        $reader = New-Object System.IO.StreamReader($ssEntry.Open())
        [xml]$ssXml = $reader.ReadToEnd(); $reader.Close()
        $strings = $ssXml.sst.si | ForEach-Object {
            if ($_.t) { $_.t }
            elseif ($_.r) { ($_.r | ForEach-Object { $_.t }) -join '' }
            else { '' }
        }
    }
    $se = $zip.Entries | Where-Object { $_.FullName -eq 'xl/worksheets/sheet1.xml' }
    $reader2 = New-Object System.IO.StreamReader($se.Open())
    [xml]$sx = $reader2.ReadToEnd(); $reader2.Close(); $zip.Dispose()
    $result = @()
    foreach ($row in $sx.worksheet.sheetData.row) {
        $rd = @()
        foreach ($c in $row.c) {
            if ($c.t -eq 's') { $rd += $strings[[int]$c.v] } else { $rd += $c.v }
        }
        $result += ,$rd
    }
    return $result
}

Write-Host "====== INTERFACE DEFINITION (aif_t_finf_de) ======"
$rows = ReadXlsx 'aif_t_finf_de.xlsx'
$h = $rows[0]
foreach ($i in 1..($rows.Count-1)) {
    $r = $rows[$i]
    if ($r.Count -gt 2 -and $r[1] -eq $NS -and $r[2] -eq $IfName) {
        for ($j = 0; $j -lt $h.Count; $j++) {
            if ($j -lt $r.Count -and $r[$j] -and $r[$j] -ne '' -and $r[$j] -ne '0') {
                Write-Host ("  $($h[$j]) = $($r[$j])")
            }
        }
    }
}

Write-Host ""
Write-Host "====== ACTIONS (aif_t_ifact) ======"
$rows2 = ReadXlsx 'aif_t_ifact.xlsx'
$h2 = $rows2[0]
Write-Host ("  " + ($h2 -join " | "))
$actions = @()
foreach ($i in 1..($rows2.Count-1)) {
    $r = $rows2[$i]
    if ($r.Count -gt 2 -and $r[1] -eq $NS -and $r[2] -eq $IfName) {
        Write-Host ("  " + ($r -join " | "))
        if ($r.Count -gt 6) { $actions += $r[6] }  # IFACTION
    }
}

Write-Host ""
Write-Host "====== FUNCTIONS (aif_t_func) for actions ======"
$rows3 = ReadXlsx 'aif_t_func.xlsx'
$h3 = $rows3[0]
Write-Host ("  " + ($h3 -join " | "))
foreach ($act in ($actions | Sort-Object -Unique)) {
    foreach ($i in 1..($rows3.Count-1)) {
        $r = $rows3[$i]
        if ($r.Count -gt 2 -and $r[2] -eq $act) {
            Write-Host ("  " + ($r -join " | "))
        }
    }
}

Write-Host ""
Write-Host "====== FIELD MAPPINGS (aif_t_fmap) - summary ======"
$rows4 = ReadXlsx 'aif_t_fmap.xlsx'
$h4 = $rows4[0]
$vmapIdx = [Array]::IndexOf($h4, 'NS_VMAPNAME')
$vmapNIdx = [Array]::IndexOf($h4, 'VMAPNAME')
$fnIdx = [Array]::IndexOf($h4, 'FIELDNAME')
$sfnIdx = [Array]::IndexOf($h4, 'SAP_FIELDNAME1')
$chkNsIdx = [Array]::IndexOf($h4, 'NSCHECK')
$chkIdx = [Array]::IndexOf($h4, 'AIFCHECK')
foreach ($i in 1..($rows4.Count-1)) {
    $r = $rows4[$i]
    if ($r.Count -gt 2 -and $r[1] -eq $NS -and $r[2] -eq $IfName) {
        $fn = if ($r.Count -gt $fnIdx) { $r[$fnIdx] } else { '' }
        $sfn = if ($r.Count -gt $sfnIdx) { $r[$sfnIdx] } else { '' }
        $vm = if ($r.Count -gt $vmapNIdx) { $r[$vmapNIdx] } else { '' }
        $chk = if ($r.Count -gt $chkIdx) { $r[$chkIdx] } else { '' }
        Write-Host ("  FIELD=$fn  SAP=$sfn  VMAP=$vm  CHECK=$chk")
    }
}
