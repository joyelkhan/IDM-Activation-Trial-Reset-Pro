<#
.SYNOPSIS
    Enterprise Deployment Example for IDM Activation Pro
    
.DESCRIPTION
    Example script demonstrating enterprise-scale deployment across multiple systems.
    This script shows how to deploy IDM Activation Pro in a corporate environment
    with centralized logging, error handling, and reporting.
    
.EXAMPLE
    .\Enterprise_Deployment.ps1
    Deploy to local system with enterprise settings
    
.EXAMPLE
    .\Enterprise_Deployment.ps1 -ComputerList "computers.txt"
    Deploy to multiple computers from a list
    
.NOTES
    Requires: Administrator privileges
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ComputerList = $null,
    
    [Parameter(Mandatory=$false)]
    [int]$TrialDays = 45,
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "C:\Logs\IDM_Deployment"
)

# =============================================
# CONFIGURATION
# =============================================

$DeploymentConfig = @{
    SilentMode = $true
    Enterprise = $true
    TrialExtensionDays = $TrialDays
    Mode = "Stealth"
    ForceBypass = $true
}

$ScriptPath = Join-Path $PSScriptRoot "..\IDM_Activation_Pro.ps1"

# =============================================
# LOGGING SETUP
# =============================================

function Write-DeploymentLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Console output
    $color = switch ($Level) {
        "INFO"    { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host $logEntry -ForegroundColor $color
    
    # File output
    if (-not (Test-Path $LogPath)) {
        New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
    }
    
    $logFile = Join-Path $LogPath "Deployment_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logEntry
}

# =============================================
# DEPLOYMENT FUNCTIONS
# =============================================

function Test-Prerequisites {
    Write-DeploymentLog "Checking prerequisites..." -Level "INFO"
    
    # Check if script exists
    if (-not (Test-Path $ScriptPath)) {
        Write-DeploymentLog "Main script not found: $ScriptPath" -Level "ERROR"
        return $false
    }
    
    # Check admin privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-DeploymentLog "Administrator privileges required!" -Level "ERROR"
        return $false
    }
    
    Write-DeploymentLog "Prerequisites check passed" -Level "SUCCESS"
    return $true
}

function Invoke-LocalDeployment {
    Write-DeploymentLog "Starting local deployment..." -Level "INFO"
    
    try {
        # Execute main script with enterprise configuration
        & $ScriptPath @DeploymentConfig
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-DeploymentLog "Local deployment completed successfully" -Level "SUCCESS"
            
            # Log deployment success
            $deploymentRecord = @{
                Timestamp = Get-Date
                Computer = $env:COMPUTERNAME
                User = $env:USERNAME
                Status = "Success"
                TrialDays = $TrialDays
            }
            
            $recordFile = Join-Path $LogPath "Deployment_Records.json"
            $deploymentRecord | ConvertTo-Json | Add-Content -Path $recordFile
            
            return $true
        } else {
            Write-DeploymentLog "Local deployment failed with exit code: $LASTEXITCODE" -Level "ERROR"
            return $false
        }
    } catch {
        Write-DeploymentLog "Local deployment exception: $_" -Level "ERROR"
        return $false
    }
}

function Invoke-RemoteDeployment {
    param([string]$ComputerName)
    
    Write-DeploymentLog "Deploying to remote computer: $ComputerName" -Level "INFO"
    
    try {
        # Test connectivity
        if (-not (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)) {
            Write-DeploymentLog "Cannot reach $ComputerName" -Level "WARNING"
            return $false
        }
        
        # Copy script to remote computer
        $remotePath = "\\$ComputerName\C$\Temp\IDM_Activation_Pro.ps1"
        Copy-Item -Path $ScriptPath -Destination $remotePath -Force
        
        # Execute remotely using Invoke-Command
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            param($Config)
            & "C:\Temp\IDM_Activation_Pro.ps1" @Config
        } -ArgumentList $DeploymentConfig | Out-Null
        
        Write-DeploymentLog "Remote deployment to $ComputerName completed" -Level "SUCCESS"
        return $true
        
    } catch {
        Write-DeploymentLog "Remote deployment to $ComputerName failed: $_" -Level "ERROR"
        return $false
    }
}

# =============================================
# REPORTING
# =============================================

function New-DeploymentReport {
    param(
        [int]$TotalComputers,
        [int]$SuccessCount,
        [int]$FailureCount
    )
    
    $reportPath = Join-Path $LogPath "Deployment_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>IDM Deployment Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .summary { background: #f0f0f0; padding: 15px; border-radius: 5px; }
        .success { color: green; }
        .failure { color: red; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
    </style>
</head>
<body>
    <h1>IDM Activation Pro - Deployment Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Date:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p><strong>Total Computers:</strong> $TotalComputers</p>
        <p class="success"><strong>Successful:</strong> $SuccessCount</p>
        <p class="failure"><strong>Failed:</strong> $FailureCount</p>
        <p><strong>Success Rate:</strong> $([math]::Round(($SuccessCount / $TotalComputers) * 100, 2))%</p>
    </div>
</body>
</html>
"@
    
    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-DeploymentLog "Report generated: $reportPath" -Level "SUCCESS"
}

# =============================================
# MAIN EXECUTION
# =============================================

function Start-EnterpriseDeployment {
    Write-Host "`n" + ("="*80) -ForegroundColor Cyan
    Write-Host "IDM Activation Pro - Enterprise Deployment" -ForegroundColor Cyan
    Write-Host ("="*80) -ForegroundColor Cyan
    Write-Host ""
    
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-DeploymentLog "Prerequisites check failed. Exiting." -Level "ERROR"
        return
    }
    
    $successCount = 0
    $failureCount = 0
    $totalComputers = 0
    
    # Local or remote deployment
    if ($ComputerList -and (Test-Path $ComputerList)) {
        # Deploy to multiple computers
        $computers = Get-Content $ComputerList
        $totalComputers = $computers.Count
        
        Write-DeploymentLog "Deploying to $totalComputers computers..." -Level "INFO"
        
        foreach ($computer in $computers) {
            if (Invoke-RemoteDeployment -ComputerName $computer) {
                $successCount++
            } else {
                $failureCount++
            }
        }
    } else {
        # Local deployment only
        $totalComputers = 1
        
        if (Invoke-LocalDeployment) {
            $successCount = 1
        } else {
            $failureCount = 1
        }
    }
    
    # Generate report
    New-DeploymentReport -TotalComputers $totalComputers -SuccessCount $successCount -FailureCount $failureCount
    
    # Summary
    Write-Host "`n" + ("="*80) -ForegroundColor Cyan
    Write-Host "DEPLOYMENT SUMMARY" -ForegroundColor Cyan
    Write-Host ("="*80) -ForegroundColor Cyan
    Write-Host "Total Computers: $totalComputers" -ForegroundColor White
    Write-Host "Successful: $successCount" -ForegroundColor Green
    Write-Host "Failed: $failureCount" -ForegroundColor Red
    Write-Host ("="*80) -ForegroundColor Cyan
}

# Execute deployment
Start-EnterpriseDeployment
