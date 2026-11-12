$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$venvPython = Join-Path $root '.venv\Scripts\python.exe'
$pythonCommand = Get-Command python -ErrorAction SilentlyContinue
$pythonExe = if (Test-Path $venvPython) { $venvPython } elseif ($pythonCommand) { $pythonCommand.Source } else { $null }
$nodeDir = Join-Path $root '.tools\node-v26.13.0-win-x64'
$localNode = Join-Path $nodeDir 'node.exe'
$localNpm = Join-Path $nodeDir 'npm.cmd'
$nodeCommand = Get-Command node -ErrorAction SilentlyContinue
$npmCommand = Get-Command npm -ErrorAction SilentlyContinue
$nodeExe = if (Test-Path $localNode) { $localNode } elseif ($nodeCommand) { $nodeCommand.Source } else { $null }
$npmExe = if (Test-Path $localNpm) { $localNpm } elseif ($npmCommand) { $npmCommand.Source } else { $null }

if (-not $pythonExe) {
    if ($nodeExe) { Start-Process -FilePath $nodeExe -ArgumentList 'runtime/server.mjs' -WorkingDirectory $root -WindowStyle Hidden; Write-Output 'Mendaly local fallback: http://localhost:8000'; return }
    throw 'Python 3.11+ or Node.js 20+ was not found. Install a supported runtime, then rerun start.ps1.'
}
if (-not (Test-Path $venvPython)) {
    & $pythonExe -m venv $root\.venv
    if ($LASTEXITCODE -ne 0) { throw 'Failed to create the project Python virtual environment.' }
    $pythonExe = $venvPython
}
if (-not $nodeExe -or -not $npmExe) { throw 'Node.js/npm were not found. Install Node.js 20+ to run the web client.' }
$env:PATH = "$(Split-Path -Parent $nodeExe);$env:PATH"
& $pythonExe -m pip install -r (Join-Path $root 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'Python dependency installation failed.' }
Push-Location (Join-Path $root 'frontend')
try { & $npmExe install --no-audit --no-fund } finally { Pop-Location }
if ($LASTEXITCODE -ne 0) { throw 'Frontend dependency installation failed.' }
Start-Process -FilePath $pythonExe -ArgumentList '-m','uvicorn','app.main:app','--host','127.0.0.1','--port','8000' -WorkingDirectory $root -WindowStyle Hidden
Start-Process -FilePath $npmExe -ArgumentList 'run','dev','--','--host','127.0.0.1' -WorkingDirectory (Join-Path $root 'frontend') -WindowStyle Hidden
Write-Output 'Mendaly API: http://localhost:8000/docs'
Write-Output 'Mendaly Web: http://localhost:5173'
