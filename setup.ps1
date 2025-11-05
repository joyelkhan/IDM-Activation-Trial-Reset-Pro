<#
.SYNOPSIS
    IDM Activation Pro - Setup Wizard
.DESCRIPTION
    Guided setup and configuration wizard
.AUTHOR
    MD. Abu Naser Khan
.VERSION
    2.2.0
#>

function Show-SetupWizard {
    Clear-Host
    Write-Host ""
    Write-Host "    ╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "    ║           IDM ACTIVATION PRO SETUP           ║" -ForegroundColor Cyan
    Write-Host "    ║                Configuration Wizard          ║" -ForegroundColor Cyan
    Write-Host "    ╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    Welcome to the setup wizard!" -ForegroundColor Yellow
    Write-Host "    This will guide you through initial configuration." -ForegroundColor Gray
    Write-Host ""
}

function Get-UserPreferences {
    Write-Host "📋 Configuration Options:" -ForegroundColor White
    Write-Host ""
    
    $preferences = @{}
    
    # Execution Mode
    Write-Host "1. Select Execution Mode:" -ForegroundColor Cyan
    Write-Host "   [1] Normal Mode (Recommended)" -ForegroundColor Gray
    Write-Host "   [2] Stealth Mode (Advanced)" -ForegroundColor Gray
    Write-Host "   [3] Enterprise Mode (IT Professionals)" -ForegroundColor Gray
    
    $modeChoice = Read-Host "`nEnter choice (1-3)"
    switch ($modeChoice) {
        "1" { $preferences.Mode = "Normal" }
        "2" { $preferences.Mode = "Stealth" }
        "3" { $preferences.Mode = "Enterprise" }
        default { $preferences.Mode = "Normal" }
    }
    
    # Trial Extension
    Write-Host "`n2. Trial Extension Period:" -ForegroundColor Cyan
    Write-Host "   How many days to extend trial?" -ForegroundColor Gray
    $days = Read-Host "`nEnter days (30-365)"
    $preferences.TrialDays = if ($days -match '^\d+$' -and [int]$days -ge 30 -and [int]$days -le 365) { [int]$days } else { 30 }
    
    # Auto Cleanup
    Write-Host "`n3. Automatic Cleanup:" -ForegroundColor Cyan
    Write-Host "   Enable automatic evidence cleanup?" -ForegroundColor Gray
    $cleanup = Read-Host "(Y/N)"
    $preferences.AutoCleanup = $cleanup -match '^[Yy]'
    
    # Create Configuration File
    $configPath = "$PSScriptRoot\config.json"
    $preferences | ConvertTo-Json | Out-File $configPath -Encoding UTF8
    
    return $preferences
}

function Complete-Setup {
    param($preferences)
    
    Write-Host "`n"
    Write-Host "    ╔══════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "    ║               SETUP COMPLETE!                ║" -ForegroundColor Green
    Write-Host "    ╚══════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "    ✅ Configuration Summary:" -ForegroundColor White
    Write-Host "    Mode: $($preferences.Mode)" -ForegroundColor Gray
    Write-Host "    Trial Extension: $($preferences.TrialDays) days" -ForegroundColor Gray
    Write-Host "    Auto Cleanup: $(if($preferences.AutoCleanup){'Enabled'}else{'Disabled'})" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    🚀 You're ready to use IDM Activation Pro!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    Quick Commands:" -ForegroundColor Cyan
    Write-Host "    - Normal use: .\IDM_Activation_Pro.ps1" -ForegroundColor Gray
    Write-Host "    - Silent mode: .\IDM_Activation_Pro.ps1 -Silent" -ForegroundColor Gray
    Write-Host "    - Enterprise: .\IDM_Activation_Pro.ps1 -Enterprise" -ForegroundColor Gray
    Write-Host ""
    
    # Countdown and exit
    Write-Host "    Closing setup in: " -NoNewline -ForegroundColor Yellow
    for ($i = 5; $i -gt 0; $i--) {
        Write-Host "$i " -NoNewline -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
    Write-Host "`n"
}

# Main wizard execution
Show-SetupWizard
$prefs = Get-UserPreferences
Complete-Setup -preferences $prefs
