$ErrorActionPreference = 'Stop'

$pythonCmd = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonCmd = 'py'
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = 'python'
} else {
    throw 'Python was not found on PATH.'
}

& $pythonCmd -m pip install --upgrade pip
& $pythonCmd -m pip install -r requirements.txt
& $pythonCmd .agents/skills/universal-file-reader/scripts/self_test.py

Write-Host 'Universal File Reader setup complete.'
