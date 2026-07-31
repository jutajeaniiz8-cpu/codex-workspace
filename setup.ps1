$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $false)][string[]]$Arguments = @()
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $FilePath $($Arguments -join ' ')"
    }
}

function Test-Py312Launcher {
    if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
        return $false
    }

    # Run the probe through cmd.exe so Windows PowerShell does not treat py.exe stderr
    # as a terminating NativeCommandError when Python 3.12 is not installed.
    & cmd.exe /d /c 'py -3.12 -c "import sys; raise SystemExit(0 if sys.version_info[:2] == (3, 12) else 1)" >nul 2>nul'
    return ($LASTEXITCODE -eq 0)
}

function Find-Python312Executable {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'),
        (Join-Path $env:ProgramFiles 'Python312\python.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Python312\python.exe')
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    return $null
}

$pythonFile = $null
$pythonPrefix = @()

if (Test-Py312Launcher) {
    $pythonFile = 'py'
    $pythonPrefix = @('-3.12')
} else {
    $pythonFile = Find-Python312Executable
}

if (-not $pythonFile) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Python 3.12 is not installed and winget is unavailable.'
    }

    Write-Host 'Python 3.12 is not installed. Installing exact package Python.Python.3.12 from WinGet...'
    Invoke-Checked -FilePath 'winget' -Arguments @(
        'install', '--id', 'Python.Python.3.12', '-e', '--source', 'winget',
        '--accept-package-agreements', '--accept-source-agreements'
    )

    if (Test-Py312Launcher) {
        $pythonFile = 'py'
        $pythonPrefix = @('-3.12')
    } else {
        $pythonFile = Find-Python312Executable
        $pythonPrefix = @()
    }

    if (-not $pythonFile) {
        throw 'Python 3.12 was installed, but this shell cannot locate python.exe. Close PowerShell, open a new PowerShell window, cd back to this repository, and rerun setup.ps1.'
    }
}

Write-Host 'Using Python 3.12 for Universal File Reader.'

$venvDir = Join-Path $PSScriptRoot '.venv'
$venvPython = Join-Path $venvDir 'Scripts\python.exe'

if (Test-Path $venvDir) {
    if (-not (Test-Path $venvPython)) {
        Remove-Item -Recurse -Force $venvDir
    }
}

if (-not (Test-Path $venvPython)) {
    $venvArgs = @($pythonPrefix) + @('-m', 'venv', $venvDir)
    Invoke-Checked -FilePath $pythonFile -Arguments $venvArgs
}

Invoke-Checked -FilePath $venvPython -Arguments @('-m', 'pip', 'install', '--upgrade', 'pip')
Invoke-Checked -FilePath $venvPython -Arguments @('-m', 'pip', 'install', '-r', 'requirements.txt')
Invoke-Checked -FilePath $venvPython -Arguments @('.agents/skills/universal-file-reader/scripts/self_test.py')

Write-Host ''
Write-Host 'Universal File Reader setup complete.' -ForegroundColor Green
Write-Host "Runtime: $venvPython"
Write-Host 'SELF-TEST PASS' -ForegroundColor Green
