<#
.SYNOPSIS
    Scheduled Reset Example for IDM Activation Pro
    
.DESCRIPTION
    Example script for automated scheduled trial resets using Windows Task Scheduler.
    This script demonstrates how to set up automated IDM trial resets on a schedule.
    
.PARAMETER Schedule
    Schedule frequency: Daily, Weekly, or Monthly
    
.PARAMETER Time
    Time of day to run the task (24-hour format, e.g., "03:00")
    
.PARAMETER TaskName
    Name for the scheduled task
    
.EXAMPLE
    .\Scheduled_Reset.ps1 -Schedule Weekly -Time "03:00"
    Create a weekly scheduled task at 3:00 AM
    
.EXAMPLE
    .\Scheduled_Reset.ps1 -Schedule Daily -Time "02:30" -TaskName "IDM-Daily-Reset"
    Create a daily scheduled task at 2:30 AM
    
.NOTES
    Requires: Administrator privileges
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Daily", "Weekly", "Monthly")]
    [string]$Schedule = "Weekly",
    
    [Parameter(Mandatory=$false)]
    [ValidatePattern('^\d{2}:\d{2}$')]
    [string]$Time = "03:00",
    
    [Parameter(Mandatory=$false)]
    [string]$TaskName = "IDM-Trial-Reset-Auto"
)

# =============================================
# CONFIGURATION
# =============================================

$ScriptPath = Join-Path $PSScriptRoot "..\IDM_Activation_Pro.ps1"
$LogPath = "$env:TEMP\IDM_Scheduled_Tasks.log"

# Task configuration
$TaskConfig = @{
    TaskName = $TaskName
    ScriptPath = $ScriptPath
    Arguments = "-ResetOnly -Silent -StealthMode"
    Schedule = $Schedule
    Time = $Time
}

# =============================================
# LOGGING
# =============================================

function Write-TaskLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        "INFO"    { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host $logEntry -ForegroundColor $color
    
    Add-Content -Path $LogPath -Value $logEntry
}

# =============================================
# SCHEDULED TASK FUNCTIONS
# =============================================

function Test-TaskPrerequisites {
    Write-TaskLog "Checking prerequisites..." -Level "INFO"
    
    # Check admin privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-TaskLog "Administrator privileges required to create scheduled tasks!" -Level "ERROR"
        return $false
    }
    
    # Check if script exists
    if (-not (Test-Path $ScriptPath)) {
        Write-TaskLog "Main script not found: $ScriptPath" -Level "ERROR"
        return $false
    }
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-TaskLog "Task '$TaskName' already exists" -Level "WARNING"
        $response = Read-Host "Do you want to replace it? (Y/N)"
        if ($response -ne 'Y') {
            Write-TaskLog "Operation cancelled by user" -Level "INFO"
            return $false
        }
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-TaskLog "Existing task removed" -Level "INFO"
    }
    
    Write-TaskLog "Prerequisites check passed" -Level "SUCCESS"
    return $true
}

function New-ScheduledIDMReset {
    param(
        [string]$TaskName,
        [string]$ScriptPath,
        [string]$Arguments,
        [string]$Schedule,
        [string]$Time
    )
    
    Write-TaskLog "Creating scheduled task: $TaskName" -Level "INFO"
    
    try {
        # Create action
        $action = New-ScheduledTaskAction `
            -Execute "PowerShell.exe" `
            -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" $Arguments"
        
        # Create trigger based on schedule
        $trigger = switch ($Schedule) {
            "Daily" {
                New-ScheduledTaskTrigger -Daily -At $Time
            }
            "Weekly" {
                New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At $Time
            }
            "Monthly" {
                New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Sunday -At $Time
            }
        }
        
        # Create settings
        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -RunOnlyIfNetworkAvailable:$false `
            -Hidden
        
        # Create principal (run with highest privileges)
        $principal = New-ScheduledTaskPrincipal `
            -UserId "SYSTEM" `
            -LogonType ServiceAccount `
            -RunLevel Highest
        
        # Register task
        Register-ScheduledTask `
            -TaskName $TaskName `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Principal $principal `
            -Description "Automated IDM trial reset - Created by IDM Activation Pro" | Out-Null
        
        Write-TaskLog "Scheduled task created successfully!" -Level "SUCCESS"
        return $true
        
    } catch {
        Write-TaskLog "Failed to create scheduled task: $_" -Level "ERROR"
        return $false
    }
}

function Get-TaskDetails {
    param([string]$TaskName)
    
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    
    if ($task) {
        Write-Host "`n" + ("="*80) -ForegroundColor Green
        Write-Host "SCHEDULED TASK DETAILS" -ForegroundColor Green
        Write-Host ("="*80) -ForegroundColor Green
        Write-Host "Task Name: $($task.TaskName)" -ForegroundColor White
        Write-Host "State: $($task.State)" -ForegroundColor White
        Write-Host "Last Run: $($task.LastRunTime)" -ForegroundColor White
        Write-Host "Next Run: $($task.NextRunTime)" -ForegroundColor White
        Write-Host "Description: $($task.Description)" -ForegroundColor White
        Write-Host ("="*80) -ForegroundColor Green
    }
}

function Test-ScheduledTask {
    param([string]$TaskName)
    
    Write-TaskLog "Testing scheduled task..." -Level "INFO"
    
    try {
        Start-ScheduledTask -TaskName $TaskName
        Write-TaskLog "Task started successfully. Check Task Scheduler for results." -Level "SUCCESS"
        
        # Wait a moment and check status
        Start-Sleep -Seconds 5
        $task = Get-ScheduledTask -TaskName $TaskName
        Write-TaskLog "Task Status: $($task.State)" -Level "INFO"
        
    } catch {
        Write-TaskLog "Failed to test task: $_" -Level "ERROR"
    }
}

# =============================================
# MANAGEMENT FUNCTIONS
# =============================================

function Show-TaskManagementMenu {
    Write-Host "`n" + ("="*80) -ForegroundColor Cyan
    Write-Host "SCHEDULED TASK MANAGEMENT" -ForegroundColor Cyan
    Write-Host ("="*80) -ForegroundColor Cyan
    Write-Host "1. View task details" -ForegroundColor White
    Write-Host "2. Test task now" -ForegroundColor White
    Write-Host "3. Disable task" -ForegroundColor White
    Write-Host "4. Enable task" -ForegroundColor White
    Write-Host "5. Delete task" -ForegroundColor White
    Write-Host "6. Exit" -ForegroundColor White
    Write-Host ("="*80) -ForegroundColor Cyan
    
    $choice = Read-Host "Select an option (1-6)"
    
    switch ($choice) {
        "1" {
            Get-TaskDetails -TaskName $TaskName
            Show-TaskManagementMenu
        }
        "2" {
            Test-ScheduledTask -TaskName $TaskName
            Show-TaskManagementMenu
        }
        "3" {
            Disable-ScheduledTask -TaskName $TaskName
            Write-TaskLog "Task disabled" -Level "SUCCESS"
            Show-TaskManagementMenu
        }
        "4" {
            Enable-ScheduledTask -TaskName $TaskName
            Write-TaskLog "Task enabled" -Level "SUCCESS"
            Show-TaskManagementMenu
        }
        "5" {
            $confirm = Read-Host "Are you sure you want to delete the task? (Y/N)"
            if ($confirm -eq 'Y') {
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
                Write-TaskLog "Task deleted" -Level "SUCCESS"
            }
        }
        "6" {
            Write-TaskLog "Exiting..." -Level "INFO"
        }
        default {
            Write-Host "Invalid option" -ForegroundColor Red
            Show-TaskManagementMenu
        }
    }
}

# =============================================
# MAIN EXECUTION
# =============================================

function Start-ScheduledTaskSetup {
    Write-Host "`n" + ("="*80) -ForegroundColor Magenta
    Write-Host "IDM Activation Pro - Scheduled Reset Setup" -ForegroundColor Magenta
    Write-Host ("="*80) -ForegroundColor Magenta
    Write-Host ""
    
    # Check prerequisites
    if (-not (Test-TaskPrerequisites)) {
        Write-TaskLog "Setup cancelled" -Level "WARNING"
        return
    }
    
    # Display configuration
    Write-Host "Configuration:" -ForegroundColor Yellow
    Write-Host "  Task Name: $TaskName" -ForegroundColor White
    Write-Host "  Schedule: $Schedule" -ForegroundColor White
    Write-Host "  Time: $Time" -ForegroundColor White
    Write-Host "  Script: $ScriptPath" -ForegroundColor White
    Write-Host ""
    
    # Confirm
    $confirm = Read-Host "Create scheduled task with this configuration? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-TaskLog "Setup cancelled by user" -Level "INFO"
        return
    }
    
    # Create task
    $success = New-ScheduledIDMReset @TaskConfig
    
    if ($success) {
        Get-TaskDetails -TaskName $TaskName
        
        Write-Host "`nWould you like to:" -ForegroundColor Yellow
        Write-Host "1. Test the task now" -ForegroundColor White
        Write-Host "2. Manage the task" -ForegroundColor White
        Write-Host "3. Exit" -ForegroundColor White
        
        $choice = Read-Host "Select an option (1-3)"
        
        switch ($choice) {
            "1" { Test-ScheduledTask -TaskName $TaskName }
            "2" { Show-TaskManagementMenu }
            "3" { Write-TaskLog "Setup complete" -Level "SUCCESS" }
        }
    }
}

# Execute setup
Start-ScheduledTaskSetup
