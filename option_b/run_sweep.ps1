# run_sweep.ps1 — 5-point xKN composition sweep for Option B.        NEW [B5]
# For each composition: writes sweep_xKN.txt (grenade06.m's override hook),
# clears any stale checkpoint, runs grenade06 -> make_figures in one MATLAB
# batch session, then archives figs/ + history/output/snapshots into
# results/xKN0##/ before the next composition overwrites the working files.
#
# Usage: powershell -File run_sweep.ps1   (run from the option_b folder, or
# it cd's there itself)

$root = "C:\CFD\CFD-Project\option_b"
Set-Location $root

$xKNs = 0.55, 0.65, 0.70, 0.75, 0.80

foreach ($xKN in $xKNs) {
    $tag = "xKN{0:D3}" -f [int]([math]::Round($xKN * 100))
    Write-Host "=== [$((Get-Date).ToString('HH:mm:ss'))] Starting $tag (xKN=$xKN) ==="

    Set-Content -Path "sweep_xKN.txt" -Value $xKN -NoNewline -Encoding ascii

    if (Test-Path "checkpoint.mat") { Remove-Item "checkpoint.mat" -Force }
    if (Test-Path "figs")           { Remove-Item "figs" -Recurse -Force }

    & matlab -batch "grenade06; make_figures" 2>&1 |
        Tee-Object -FilePath "sweep_$tag`_console.log"

    $archive = Join-Path $root "results\$tag"
    New-Item -ItemType Directory -Force -Path $archive | Out-Null
    if (Test-Path "figs")                 { Move-Item "figs" $archive -Force }
    if (Test-Path "grenade_history.txt")  { Move-Item "grenade_history.txt" $archive -Force }
    if (Test-Path "grenade_output.txt")   { Move-Item "grenade_output.txt" $archive -Force }
    if (Test-Path "snapshots.mat")        { Move-Item "snapshots.mat" $archive -Force }
    Move-Item "sweep_$tag`_console.log" $archive -Force

    Write-Host "=== [$((Get-Date).ToString('HH:mm:ss'))] Finished $tag -> $archive ==="
}

Remove-Item "sweep_xKN.txt" -Force -ErrorAction SilentlyContinue
Write-Host "Sweep complete. Results in $root\results\"
