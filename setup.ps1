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

function Get-Python312 {
    # Prefer the Windows Python launcher when Python 3.12 is already installed.
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3.12 -c "import sys; assert sys.version_info[:2] == (3, 12)" 2>$null
        if ($LASTEXITCODE -eq 0) {
            return [PSCustomObject]@{ FilePath = 'py'; Prefix = @('-3.12') }
        }
    }

    # Accept PATH python only when it is exactly Python 3.12.
    if (Get-Command python -ErrorAction SilentlyContinue) {
        $version = & python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
        if ($LASTEXITCODE -eq 0 -and $version.Trim() -eq '3.12') {
            return [PSCustomObject]@{ FilePath = 'python'; Prefix = @() }
        }
    }

    return $null
}

$python = Get-Python312

if ($null -eq $python) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Python 3.12 is required, but it is not installed and winget is unavailable.'
    }

    Write-Host 'Python 3.12 was not found. Installing Python 3.12 with winget...'
    Invoke-Checked -FilePath 'winget' -Arguments @(
        'install', '--id', 'Python.Python.3.12', '-e', '--source', 'winget',
        '--accept-package-agreements', '--accept-source-agreements'
    )

    # Re-check the launcher/PATH after installation.
    $python = Get-Python312

    if ($null -eq $python) {
        $candidatePaths = @(
            (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'),
            (Join-Path $env:ProgramFiles 'Python312\python.exe')
        )
        foreach ($candidate in $candidatePaths) {
            if (Test-Path $candidate) {
                $python = [PSCustomObject]@{ FilePath = $candidate; Prefix = @() }
                break
            }
        }
    }

    if ($null -eq $python) {
        throw 'Python 3.12 installation completed, but this shell cannot locate it. Close PowerShell, open it again, and rerun setup.ps1.'
    }
}

Write-Host 'Using Python 3.12 for the Universal File Reader.'

$venvDir = Join-Path $PSScriptRoot '.venv'
$venvPython = Join-Path $venvDir 'Scripts\python.exe'

if (-not (Test-Path $venvPython)) {
    $venvArgs = @($python.Prefix) + @('-m', 'venv', $venvDir)
    Invoke-Checked -FilePath $python.FilePath -Arguments $venvArgs
}

Invoke-Checked -FilePath $venvPython -Arguments @('-m', 'pip', 'install', '--upgrade', 'pip')
Invoke-Checked -FilePath $venvPython -Arguments @('-m', 'pip', 'install', '-r', 'requirements.txt')
Invoke-Checked -FilePath $venvPython -Arguments @('.agents/skills/universal-file-reader/scripts/self_test.py')

Write-Host ''
Write-Host 'Universal File Reader setup complete.' -ForegroundColor Green
Write-Host "Runtime: $venvPython"
Write-Host 'SELF-TEST PASS' -ForegroundColor Green
