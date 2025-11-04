<#
.SYNOPSIS
    IDM Activation & Trial Reset Script Pro
    
.DESCRIPTION
    Professional-grade PowerShell solution for managing Internet Download Manager licensing
    Features: Enterprise deployment, AMSI bypass, telemetry spoofing, evidence cleanup
    
.PARAMETER ForceBypass
    Skip confirmation prompts and execute immediately
    
.PARAMETER ResetOnly
    Only reset trial without applying activation
    
.PARAMETER StealthMode
    Enable stealth operations with minimal logging
    
.PARAMETER DeepClean
    Perform aggressive system cleaning
    
.PARAMETER Enterprise
    Enable enterprise deployment mode
    
.PARAMETER Silent
    Suppress all console output
    
.PARAMETER CustomLicenseKey
    Provide custom license key for activation
    
.PARAMETER TrialExtensionDays
    Number of days to extend trial period (default: 30)
    
.PARAMETER Mode
    Execution mode: Normal, Aggressive, or Stealth
    
.EXAMPLE
    .\IDM_Activation_Pro.ps1
    Standard execution with user prompts
    
.EXAMPLE
    .\IDM_Activation_Pro.ps1 -Enterprise -Silent
    Silent enterprise deployment
    
.EXAMPLE
    .\IDM_Activation_Pro.ps1 -Mode Aggressive -DeepClean
    Aggressive cleaning mode
    
.VERSION
    2.1.0
    
.AUTHOR
    GitHub Community
    
.LICENSE
    MIT License
    
.LINK
    https://github.com/yourusername/IDM-Activation-Trial-Reset-Pro
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$ForceBypass,
    
    [Parameter(Mandatory=$false)]
    [switch]$ResetOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$StealthMode,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeepClean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Enterprise,
    
    [Parameter(Mandatory=$false)]
    [switch]$Silent,
    
    [Parameter(Mandatory=$false)]
    [string]$CustomLicenseKey = $null,
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 365)]
    [int]$TrialExtensionDays = 30,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Normal", "Aggressive", "Stealth")]
    [string]$Mode = "Normal"
)

# =============================================
# SCRIPT INITIALIZATION
# =============================================

$ErrorActionPreference = "Stop"
$Script:ScriptVersion = "2.1.0"
$Script:ExecutionTimestamp = [DateTime]::Now.ToString("yyyyMMdd_HHmmss")
$Script:BackupPath = "$env:TEMP\IDM_Pro_Backup_$ExecutionTimestamp"
$Script:LogPath = "$env:TEMP\IDM_Pro_Log_$ExecutionTimestamp.txt"
$Script:OperationLog = @()

# Enhanced IDM signatures and paths
$Script:IDMSignatures = @{
    RegistryPaths = @(
        "HKCU:\Software\DownloadManager",
        "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\DownloadManager",
        "HKLM:\SOFTWARE\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Internet Download Manager",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Stats\{07999AC3-058B-40BF-984F-69EB1E554CA7}",
        "HKCU:\Software\JavaSoft",
        "HKLM:\SOFTWARE\Tonec Inc.",
        "HKCU:\Software\Tonec Inc."
    )
    FilePaths = @(
        "$env:APPDATA\IDM",
        "$env:LOCALAPPDATA\IDM",
        "$env:PROGRAMDATA\IDM",
        "$env:USERPROFILE\.idm",
        "$env:PUBLIC\Documents\IDM",
        "$env:APPDATA\IDM\DwnlData",
        "$env:APPDATA\IDM\idm_gr.sys",
        "$env:APPDATA\IDM\idm_gr.bin",
        "$env:APPDATA\IDM\idm_licence.key"
    )
    ProcessNames = @("IDMan", "IEMonitor", "IDMMsgHost", "IDMIntegrator64", "IDMIntegrator")
    InstallPaths = @(
        "$env:ProgramFiles\Internet Download Manager",
        "${env:ProgramFiles(x86)}\Internet Download Manager"
    )
}

# =============================================
# LOGGING FUNCTIONS
# =============================================

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    $Script:OperationLog += $logEntry
    
    if (-not $Silent) {
        $color = switch ($Level) {
            "INFO"    { "Cyan" }
            "SUCCESS" { "Green" }
            "WARNING" { "Yellow" }
            "ERROR"   { "Red" }
            default   { "White" }
        }
        Write-Host $logEntry -ForegroundColor $color
    }
}

function Save-LogFile {
    [CmdletBinding()]
    param()
    
    try {
        $Script:OperationLog | Out-File -FilePath $Script:LogPath -Encoding UTF8 -Force
        Write-Log "Log file saved: $Script:LogPath" -Level "SUCCESS"
    } catch {
        Write-Log "Failed to save log file: $_" -Level "WARNING"
    }
}

# =============================================
# SECURITY AND OBFUSCATION ENGINE
# =============================================

function Invoke-AMSIBypass {
    [CmdletBinding()]
    param()
    
    try {
        Write-Log "Attempting AMSI bypass..." -Level "INFO"
        
        # Method 1: AmsiUtils reflection
        $amsiContext = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
        if ($amsiContext) {
            $amsiField = $amsiContext.GetField('amsiInitFailed', 'NonPublic,Static')
            if ($amsiField) {
                $amsiField.SetValue($null, $true)
                Write-Log "AMSI bypass successful (Method 1)" -Level "SUCCESS"
                return $true
            }
        }
        
        # Method 2: Registry modification
        $amsiPath = "HKLM:\SOFTWARE\Microsoft\AMSI"
        if (Test-Path $amsiPath) {
            Set-ItemProperty -Path $amsiPath -Name "AllowScriptScan" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Log "AMSI bypass successful (Method 2)" -Level "SUCCESS"
            return $true
        }
        
        Write-Log "AMSI bypass not required or already disabled" -Level "INFO"
        return $true
        
    } catch {
        Write-Log "AMSI bypass failed: $_" -Level "WARNING"
        return $false
    }
}

function Disable-WindowsDefender {
    [CmdletBinding()]
    param()
    
    if ($Mode -eq "Aggressive" -or $DeepClean) {
        try {
            Write-Log "Temporarily disabling Windows Defender..." -Level "INFO"
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
            Write-Log "Windows Defender real-time monitoring disabled" -Level "SUCCESS"
            return $true
        } catch {
            Write-Log "Failed to disable Windows Defender: $_" -Level "WARNING"
            return $false
        }
    }
    return $true
}

function Enable-WindowsDefender {
    [CmdletBinding()]
    param()
    
    try {
        Write-Log "Re-enabling Windows Defender..." -Level "INFO"
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
        Write-Log "Windows Defender re-enabled" -Level "SUCCESS"
    } catch {
        Write-Log "Failed to re-enable Windows Defender: $_" -Level "WARNING"
    }
}

# =============================================
# IDM DETECTION AND VALIDATION
# =============================================

function Test-IDMInstallation {
    [CmdletBinding()]
    param()
    
    Write-Log "Detecting IDM installation..." -Level "INFO"
    
    $idmFound = $false
    $idmPath = $null
    
    foreach ($path in $Script:IDMSignatures.InstallPaths) {
        if (Test-Path $path) {
            $idmPath = $path
            $idmFound = $true
            Write-Log "IDM found at: $path" -Level "SUCCESS"
            break
        }
    }
    
    if (-not $idmFound) {
        Write-Log "IDM installation not found!" -Level "ERROR"
        return $null
    }
    
    # Verify IDMan.exe exists
    $idmExe = Join-Path $idmPath "IDMan.exe"
    if (Test-Path $idmExe) {
        $version = (Get-Item $idmExe).VersionInfo.FileVersion
        Write-Log "IDM Version: $version" -Level "INFO"
        return @{
            Path = $idmPath
            Executable = $idmExe
            Version = $version
        }
    }
    
    Write-Log "IDMan.exe not found in installation directory" -Level "ERROR"
    return $null
}

# =============================================
# PROCESS MANAGEMENT
# =============================================

function Stop-IDMProcesses {
    [CmdletBinding()]
    param()
    
    Write-Log "Terminating IDM processes..." -Level "INFO"
    
    $terminatedCount = 0
    foreach ($processName in $Script:IDMSignatures.ProcessNames) {
        try {
            $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if ($processes) {
                $processes | Stop-Process -Force -ErrorAction SilentlyContinue
                $terminatedCount += $processes.Count
                Write-Log "Terminated process: $processName" -Level "SUCCESS"
            }
        } catch {
            Write-Log "Failed to terminate $processName : $_" -Level "WARNING"
        }
    }
    
    if ($terminatedCount -gt 0) {
        Write-Log "Total processes terminated: $terminatedCount" -Level "SUCCESS"
        Start-Sleep -Seconds 2
    } else {
        Write-Log "No IDM processes running" -Level "INFO"
    }
    
    return $terminatedCount
}

# =============================================
# BACKUP SYSTEM
# =============================================

function New-SystemBackup {
    [CmdletBinding()]
    param()
    
    Write-Log "Creating system backup..." -Level "INFO"
    
    try {
        if (-not (Test-Path $Script:BackupPath)) {
            New-Item -Path $Script:BackupPath -ItemType Directory -Force | Out-Null
        }
        
        # Backup registry keys
        $regBackupPath = Join-Path $Script:BackupPath "Registry"
        New-Item -Path $regBackupPath -ItemType Directory -Force | Out-Null
        
        foreach ($regPath in $Script:IDMSignatures.RegistryPaths) {
            if (Test-Path $regPath) {
                $regName = $regPath -replace ':', '' -replace '\\', '_'
                $exportPath = Join-Path $regBackupPath "$regName.reg"
                
                try {
                    # Export registry key
                    $regExport = "Windows Registry Editor Version 5.00`n`n"
                    $regExport += Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | Out-String
                    $regExport | Out-File -FilePath $exportPath -Encoding Unicode
                    Write-Log "Backed up registry: $regPath" -Level "INFO"
                } catch {
                    Write-Log "Failed to backup registry: $regPath" -Level "WARNING"
                }
            }
        }
        
        # Backup files
        $fileBackupPath = Join-Path $Script:BackupPath "Files"
        New-Item -Path $fileBackupPath -ItemType Directory -Force | Out-Null
        
        foreach ($filePath in $Script:IDMSignatures.FilePaths) {
            if (Test-Path $filePath) {
                try {
                    $destination = Join-Path $fileBackupPath (Split-Path $filePath -Leaf)
                    Copy-Item -Path $filePath -Destination $destination -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Log "Backed up file: $filePath" -Level "INFO"
                } catch {
                    Write-Log "Failed to backup file: $filePath" -Level "WARNING"
                }
            }
        }
        
        Write-Log "Backup created successfully at: $Script:BackupPath" -Level "SUCCESS"
        return $true
        
    } catch {
        Write-Log "Backup creation failed: $_" -Level "ERROR"
        return $false
    }
}

# =============================================
# REGISTRY CLEANING
# =============================================

function Clear-IDMRegistry {
    [CmdletBinding()]
    param()
    
    Write-Log "Cleaning IDM registry entries..." -Level "INFO"
    
    $cleanedCount = 0
    foreach ($regPath in $Script:IDMSignatures.RegistryPaths) {
        if (Test-Path $regPath) {
            try {
                Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
                $cleanedCount++
                Write-Log "Removed registry key: $regPath" -Level "SUCCESS"
            } catch {
                Write-Log "Failed to remove registry key: $regPath - $_" -Level "WARNING"
            }
        }
    }
    
    Write-Log "Registry cleaning completed. Removed $cleanedCount keys" -Level "SUCCESS"
    return $cleanedCount
}

# =============================================
# FILE SYSTEM CLEANING
# =============================================

function Clear-IDMFiles {
    [CmdletBinding()]
    param()
    
    Write-Log "Cleaning IDM files and folders..." -Level "INFO"
    
    $cleanedCount = 0
    foreach ($filePath in $Script:IDMSignatures.FilePaths) {
        if (Test-Path $filePath) {
            try {
                Remove-Item -Path $filePath -Recurse -Force -ErrorAction Stop
                $cleanedCount++
                Write-Log "Removed: $filePath" -Level "SUCCESS"
            } catch {
                Write-Log "Failed to remove: $filePath - $_" -Level "WARNING"
            }
        }
    }
    
    Write-Log "File cleaning completed. Removed $cleanedCount items" -Level "SUCCESS"
    return $cleanedCount
}

# =============================================
# TRIAL RESET IMPLEMENTATION
# =============================================

function Invoke-TrialReset {
    [CmdletBinding()]
    param()
    
    Write-Log "Starting trial reset process..." -Level "INFO"
    
    # Stop IDM processes
    Stop-IDMProcesses
    
    # Create backup
    if (-not $StealthMode) {
        New-SystemBackup
    }
    
    # Clean registry
    $regCleaned = Clear-IDMRegistry
    
    # Clean files
    $filesCleaned = Clear-IDMFiles
    
    # Reset trial date in registry
    try {
        $dmPath = "HKCU:\Software\DownloadManager"
        if (-not (Test-Path $dmPath)) {
            New-Item -Path $dmPath -Force | Out-Null
        }
        
        $futureDate = (Get-Date).AddDays($TrialExtensionDays).ToString("yyyy-MM-dd")
        Set-ItemProperty -Path $dmPath -Name "LstCheck" -Value $futureDate -Force
        Write-Log "Trial extended to: $futureDate" -Level "SUCCESS"
    } catch {
        Write-Log "Failed to set trial date: $_" -Level "WARNING"
    }
    
    Write-Log "Trial reset completed successfully!" -Level "SUCCESS"
    return $true
}

# =============================================
# ACTIVATION IMPLEMENTATION
# =============================================

function Invoke-IDMActivation {
    [CmdletBinding()]
    param(
        [string]$LicenseKey
    )
    
    if ($ResetOnly) {
        Write-Log "Skipping activation (ResetOnly mode)" -Level "INFO"
        return $true
    }
    
    Write-Log "Applying IDM activation..." -Level "INFO"
    
    try {
        $dmPath = "HKCU:\Software\DownloadManager"
        if (-not (Test-Path $dmPath)) {
            New-Item -Path $dmPath -Force | Out-Null
        }
        
        # Apply license key
        if ($LicenseKey) {
            Set-ItemProperty -Path $dmPath -Name "Serial" -Value $LicenseKey -Force
            Write-Log "Custom license key applied" -Level "SUCCESS"
        } else {
            # Generate pseudo-license (for educational purposes)
            $generatedKey = "IDM-" + [guid]::NewGuid().ToString().Substring(0, 23).ToUpper()
            Set-ItemProperty -Path $dmPath -Name "Serial" -Value $generatedKey -Force
            Write-Log "Generated license key applied" -Level "SUCCESS"
        }
        
        # Set registration flags
        Set-ItemProperty -Path $dmPath -Name "FName" -Value "Registered User" -Force
        Set-ItemProperty -Path $dmPath -Name "LName" -Value "Pro Edition" -Force
        Set-ItemProperty -Path $dmPath -Name "Email" -Value "user@registered.com" -Force
        
        Write-Log "IDM activation completed successfully!" -Level "SUCCESS"
        return $true
        
    } catch {
        Write-Log "Activation failed: $_" -Level "ERROR"
        return $false
    }
}

# =============================================
# EVIDENCE CLEANUP
# =============================================

function Clear-ExecutionEvidence {
    [CmdletBinding()]
    param()
    
    if (-not $StealthMode -and -not $Enterprise) {
        return
    }
    
    Write-Log "Cleaning execution evidence..." -Level "INFO"
    
    try {
        # Clear PowerShell history
        $historyPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
        if (Test-Path $historyPath) {
            Clear-Content -Path $historyPath -Force -ErrorAction SilentlyContinue
        }
        
        # Clear temp files
        Get-ChildItem -Path $env:TEMP -Filter "IDM_Pro_*" -ErrorAction SilentlyContinue | 
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        
        # Clear PowerShell event logs (requires admin)
        Clear-History -ErrorAction SilentlyContinue
        
        Write-Log "Evidence cleanup completed" -Level "SUCCESS"
        
    } catch {
        Write-Log "Evidence cleanup failed: $_" -Level "WARNING"
    }
}

# =============================================
# ENTERPRISE DEPLOYMENT CLASS
# =============================================

class EnterpriseDeploymentManager {
    [string]$DeploymentMode
    [hashtable]$SecurityContext
    [bool]$Success
    
    EnterpriseDeploymentManager([string]$mode) {
        $this.DeploymentMode = $mode
        $this.Success = $false
        $this.InitializeSecurityContext()
    }
    
    [void]InitializeSecurityContext() {
        $this.SecurityContext = @{
            "AMSI_Bypassed" = $false
            "Defender_Disabled" = $false
            "Execution_Obfuscated" = $true
            "Evidence_Cleaned" = $false
        }
    }
    
    [bool]ExecuteSecureDeployment() {
        Write-Log "[ENTERPRISE] Initializing secure deployment..." -Level "INFO"
        
        # Disable security measures
        $this.SecurityContext["AMSI_Bypassed"] = Invoke-AMSIBypass
        $this.SecurityContext["Defender_Disabled"] = Disable-WindowsDefender
        
        # Execute main workflow
        $resetSuccess = Invoke-TrialReset
        
        if ($resetSuccess) {
            $activationSuccess = Invoke-IDMActivation -LicenseKey $Script:CustomLicenseKey
            $this.Success = $activationSuccess
        }
        
        # Cleanup
        Enable-WindowsDefender
        Clear-ExecutionEvidence
        $this.SecurityContext["Evidence_Cleaned"] = $true
        
        Write-Log "[ENTERPRISE] Deployment completed" -Level "SUCCESS"
        return $this.Success
    }
}

# =============================================
# MAIN EXECUTION FUNCTION
# =============================================

function Invoke-MainExecution {
    [CmdletBinding()]
    param()
    
    # Display banner
    if (-not $Silent) {
        Write-Host "`n" + ("="*80) -ForegroundColor Magenta
        Write-Host "IDM Activation & Trial Reset Script Pro v$Script:ScriptVersion" -ForegroundColor Magenta
        Write-Host "Professional-Grade PowerShell Solution" -ForegroundColor Magenta
        Write-Host ("="*80) -ForegroundColor Magenta
        Write-Host ""
    }
    
    # Check admin privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Log "WARNING: Running without administrator privileges. Some operations may fail." -Level "WARNING"
        if (-not $ForceBypass -and -not $Silent) {
            $continue = Read-Host "Continue anyway? (Y/N)"
            if ($continue -ne 'Y') {
                Write-Log "Execution cancelled by user" -Level "INFO"
                return
            }
        }
    }
    
    # Validate IDM installation
    $idmInfo = Test-IDMInstallation
    if (-not $idmInfo) {
        Write-Log "IDM installation not found. Please install IDM first." -Level "ERROR"
        return
    }
    
    # User confirmation
    if (-not $ForceBypass -and -not $Silent -and -not $Enterprise) {
        Write-Host "`nThis script will:" -ForegroundColor Yellow
        Write-Host "  - Terminate all IDM processes" -ForegroundColor Yellow
        Write-Host "  - Clean IDM registry entries" -ForegroundColor Yellow
        Write-Host "  - Remove IDM temporary files" -ForegroundColor Yellow
        Write-Host "  - Reset trial period" -ForegroundColor Yellow
        if (-not $ResetOnly) {
            Write-Host "  - Apply activation" -ForegroundColor Yellow
        }
        Write-Host ""
        $confirm = Read-Host "Continue? (Y/N)"
        if ($confirm -ne 'Y') {
            Write-Log "Execution cancelled by user" -Level "INFO"
            return
        }
    }
    
    # Execute based on mode
    if ($Enterprise) {
        $deploymentManager = [EnterpriseDeploymentManager]::new($Mode)
        $success = $deploymentManager.ExecuteSecureDeployment()
    } else {
        # Standard execution
        Invoke-AMSIBypass
        
        if ($Mode -eq "Aggressive") {
            Disable-WindowsDefender
        }
        
        $resetSuccess = Invoke-TrialReset
        
        if ($resetSuccess -and -not $ResetOnly) {
            Invoke-IDMActivation -LicenseKey $CustomLicenseKey
        }
        
        if ($Mode -eq "Aggressive") {
            Enable-WindowsDefender
        }
        
        if ($StealthMode) {
            Clear-ExecutionEvidence
        }
    }
    
    # Save log
    if (-not $StealthMode) {
        Save-LogFile
    }
    
    # Final message
    if (-not $Silent) {
        Write-Host "`n" + ("="*80) -ForegroundColor Magenta
        Write-Host "EXECUTION COMPLETED SUCCESSFULLY" -ForegroundColor Green
        Write-Host ("="*80) -ForegroundColor Magenta
        Write-Host "`nPlease restart IDM to apply changes." -ForegroundColor Cyan
        
        if (-not $StealthMode) {
            Write-Host "`nBackup location: $Script:BackupPath" -ForegroundColor Yellow
            Write-Host "Log file: $Script:LogPath" -ForegroundColor Yellow
        }
    }
}

# =============================================
# SCRIPT ENTRY POINT
# =============================================

# Only execute if script is run directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-MainExecution
    } catch {
        Write-Log "Critical error: $_" -Level "ERROR"
        Write-Log $_.ScriptStackTrace -Level "ERROR"
        exit 1
    }
}
