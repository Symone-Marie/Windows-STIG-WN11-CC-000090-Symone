<#
.SYNOPSIS
    This PowerShell script enables Group Policy registry policy processing even if objects have not changed.
.NOTES
    Author          : Symone-Marie Priester
    LinkedIn        : linkedin.com/in/symone-mariepriester
    GitHub          : github.com/Symone-Marie
    Date Created    : 2025-02-09
    Last Modified   : 2025-02-09
    Version         : Microsoft Windows [Version 10.0.26200.7623]
    CVEs            : N/A
    Vuln-ID         : V-253373
    STIG-ID         : WN11-CC-000090
.TESTED ON
    Date(s) Tested  : 2025-02-09
    Tested By       : Symone-Marie Priester
    Systems Tested  : Windows 11 Pro OS
    PowerShell Ver. : 5.1
    Manual Test     : Yes, remediated via Local Group Policy Editor (gpedit.msc) with screenshot documentation
.USAGE
    Enables registry policy processing to reprocess even if Group Policy objects have not changed.
    Example syntax:
    PS C:\> .\remediation_WN11-CC-000090.ps1 
#>

# Define registry path and values
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
$regNameNoBackgroundPolicy = "NoBackgroundPolicy"
$regNameNoGPOListChanges = "NoGPOListChanges"
$regValue = 0

Write-Host "Configuring Group Policy registry policy processing..."

# Create registry path if it doesn't exist
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "Created registry path: $regPath"
}

# Set NoBackgroundPolicy to 0 (Enable background processing)
Set-ItemProperty -Path $regPath -Name $regNameNoBackgroundPolicy -Value $regValue -Type DWord
Write-Host "Set $regNameNoBackgroundPolicy to $regValue"

# Set NoGPOListChanges to 0 (Process even if GPO has not changed)
Set-ItemProperty -Path $regPath -Name $regNameNoGPOListChanges -Value $regValue -Type DWord
Write-Host "Set $regNameNoGPOListChanges to $regValue"

# Verify the changes
Write-Host "`nVerifying configuration..."
$currentNoBackground = Get-ItemProperty -Path $regPath -Name $regNameNoBackgroundPolicy -ErrorAction SilentlyContinue
$currentNoGPOChanges = Get-ItemProperty -Path $regPath -Name $regNameNoGPOListChanges -ErrorAction SilentlyContinue

if ($currentNoBackground.$regNameNoBackgroundPolicy -eq $regValue -and $currentNoGPOChanges.$regNameNoGPOListChanges -eq $regValue) {
    Write-Host "SUCCESS: WN11-CC-000090 remediated - Group Policy objects will be reprocessed even if they have not changed" -ForegroundColor Green
    Write-Host "`nCurrent registry values:"
    Get-ItemProperty -Path $regPath | Select-Object NoBackgroundPolicy, NoGPOListChanges
} else {
    Write-Host "ERROR: Failed to set registry values" -ForegroundColor Red
}
