<#
.SYNOPSIS
    IDM Activation Pro - Uninstaller
.DESCRIPTION
    Clean removal of IDM Activation Pro from system
.AUTHOR
    MD. Abu Naser Khan
.VERSION
    2.2.0
#>

function Uninstall-IDMPro {
    Write-Host ""
    Write-Host "    ╔══════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "    ║           IDM ACTIVATION PRO REMOVAL         ║" -ForegroundColor Red
    Write-Host "    ║                Uninstall Wizard              ║" -ForegroundColor Red
    Write-Host "    ╚══════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    
    $confirm = Read-Host "Are you sure you want to uninstall IDM Activation Pro? (Y/N)"
    if ($confirm -notmatch '^[Yy]') {
        Write-Host "Uninstall cancelled." -ForegroundColor Yellow
        exit 0
    }
    
    $installPath = "$env:ProgramFiles\IDM Activation Pro"
    
    Write-Host "`nRemoving IDM Activation Pro..." -ForegroundColor Yellow
    Write-Host ""
    
    # Remove installation directory
    if (Test-Path $installPath) {
        Remove-Item $installPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Removed installation directory" -ForegroundColor Green
    }
    
    # Remove desktop shortcut
    $shortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "IDM Activation Pro.lnk")
    if (Test-Path $shortcutPath) {
        Remove-Item $shortcutPath -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Removed desktop shortcut" -ForegroundColor Green
    }
    
    # Remove from PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -match [Regex]::Escape($installPath)) {
        $newPath = $currentPath -replace [Regex]::Escape($installPath), "" -replace ";;", ";"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        Write-Host "✅ Removed from system PATH" -ForegroundColor Green
    }
    
    # Remove configuration files
    $configPath = "$env:APPDATA\IDM Activation Pro"
    if (Test-Path $configPath) {
        Remove-Item $configPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Removed configuration files" -ForegroundColor Green
    }
    
    Write-Host "`n🎉 IDM Activation Pro has been completely uninstalled." -ForegroundColor Green
    Write-Host "Thank you for using our software!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Developed by MD. Abu Naser Khan" -ForegroundColor Magenta
    
    # Countdown exit
    Write-Host "`nClosing in: " -NoNewline -ForegroundColor Yellow
    for ($i = 3; $i -gt 0; $i--) {
        Write-Host "$i " -NoNewline -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
    Write-Host "`n"
}

# Check for admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Please run as Administrator." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    exit 1
}

Uninstall-IDMPro
