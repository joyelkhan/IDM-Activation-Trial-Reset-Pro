<#
.SYNOPSIS
    IDM Activation Pro - Smart Installer
.DESCRIPTION
    Professional installation system with branding and validation
.AUTHOR
    MD. Abu Naser Khan
.VERSION
    2.2.0
#>

# Import branding and interface modules
$Script:Author = "MD. Abu Naser Khan"
$Script:Version = "2.2.0"
$Script:ProjectName = "IDM Activation & Trial Reset Script Pro"

# Display professional banner
function Show-BrandBanner {
    Clear-Host
    Write-Host ""
    Write-Host "    ███████╗██╗██████╗ ███╗   ███╗    █████╗  ██████╗████████╗██╗██╗   ██╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗" -ForegroundColor Cyan
    Write-Host "    ██╔════╝██║██╔══██╗████╗ ████║   ██╔══██╗██╔════╝╚══██╔══╝██║██║   ██║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║" -ForegroundColor Cyan
    Write-Host "    █████╗  ██║██║  ██║██╔████╔██║   ███████║██║        ██║   ██║██║   ██║███████║   ██║   ██║██║   ██║██╔██╗ ██║" -ForegroundColor Cyan
    Write-Host "    ██╔══╝  ██║██║  ██║██║╚██╔╝██║   ██╔══██║██║        ██║   ██║██║   ██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║" -ForegroundColor Cyan
    Write-Host "    ██║     ██║██████╔╝██║ ╚═╝ ██║   ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║" -ForegroundColor Cyan
    Write-Host "    ╚═╝     ╚═╝╚═════╝ ╚═╝     ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝ ╚═══╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "                                        🚀 Professional IDM Activation System" -ForegroundColor Yellow
    Write-Host "                                                Version $Version" -ForegroundColor Green
    Write-Host "                                              Author: $Author" -ForegroundColor Magenta
    Write-Host ""

    # System information
    Write-Host "System Check:" -ForegroundColor White
    Write-Host "  OS: $([System.Environment]::OSVersion.VersionString)" -ForegroundColor Gray
    Write-Host "  PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
    Write-Host "  Architecture: $([Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE'))" -ForegroundColor Gray
    Write-Host ""
}

# System validation function
function Test-SystemRequirements {
    Write-Host "[INSTALLER] Validating system requirements..." -ForegroundColor Cyan
    
    $requirements = @{
        "Windows 10/11" = [Environment]::OSVersion.Version -ge (new-object Version 10,0)
        "PowerShell 5.1+" = $PSVersionTable.PSVersion -ge (new-object Version 5,1)
        "Administrative Rights" = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        "IDM Installed" = (Test-Path "$env:ProgramFiles\Internet Download Manager") -or (Test-Path "${env:ProgramFiles(x86)}\Internet Download Manager")
    }
    
    $allPassed = $true
    foreach ($req in $requirements.GetEnumerator()) {
        if ($req.Value) {
            Write-Host "  ✅ $($req.Key)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($req.Key)" -ForegroundColor Red
            $allPassed = $false
        }
    }
    
    return $allPassed
}

# Installation process
function Install-IDMPro {
    param(
        [switch]$Silent,
        [switch]$Force
    )
    
    Show-BrandBanner
    
    if (-not $Silent) {
        Write-Host "Welcome to IDM Activation Pro Installer!" -ForegroundColor Yellow
        Write-Host "This will install the professional IDM management system." -ForegroundColor Gray
        Write-Host ""
        
        $confirm = Read-Host "Continue with installation? (Y/N)"
        if ($confirm -notmatch '^[Yy]') {
            Write-Host "Installation cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Validate system
    if (-not (Test-SystemRequirements) -and -not $Force) {
        Write-Host "`n[ERROR] System requirements not met." -ForegroundColor Red
        Write-Host "Please ensure all requirements are satisfied before installation." -ForegroundColor Yellow
        exit 1
    }
    
    # Create installation directory
    $installPath = "$env:ProgramFiles\IDM Activation Pro"
    Write-Host "`n[INSTALLER] Creating installation directory..." -ForegroundColor Cyan
    
    try {
        if (-not (Test-Path $installPath)) {
            New-Item -Path $installPath -ItemType Directory -Force | Out-Null
        }
        
        # Copy project files
        $filesToCopy = @(
            "IDM_Activation_Pro.ps1",
            "setup.ps1", 
            "uninstall.ps1",
            "README.md",
            "LICENSE"
        )
        
        foreach ($file in $filesToCopy) {
            if (Test-Path $file) {
                Copy-Item $file $installPath -Force
                Write-Host "  ✅ Copied: $file" -ForegroundColor Green
            }
        }
        
        # Create modules directory
        $modulesPath = Join-Path $installPath "modules"
        New-Item -Path $modulesPath -ItemType Directory -Force | Out-Null
        
        # Copy modules
        if (Test-Path "modules") {
            Copy-Item "modules\*" $modulesPath -Recurse -Force
            Write-Host "  ✅ Copied modules" -ForegroundColor Green
        }
        
        # Copy assets
        if (Test-Path "assets") {
            $assetsPath = Join-Path $installPath "assets"
            New-Item -Path $assetsPath -ItemType Directory -Force | Out-Null
            Copy-Item "assets\*" $assetsPath -Recurse -Force
            Write-Host "  ✅ Copied assets" -ForegroundColor Green
        }
        
        # Create desktop shortcut
        $shortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "IDM Activation Pro.lnk")
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$installPath\IDM_Activation_Pro.ps1`""
        $Shortcut.WorkingDirectory = $installPath
        $Shortcut.WindowStyle = 1
        $Shortcut.Description = "IDM Activation Pro - Professional IDM Management"
        $Shortcut.Save()
        
        Write-Host "  ✅ Created desktop shortcut" -ForegroundColor Green
        
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notmatch [Regex]::Escape($installPath)) {
            $newPath = $currentPath + ";" + $installPath
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-Host "  ✅ Added to system PATH" -ForegroundColor Green
        }
        
        Write-Host "`n🎉 Installation Completed Successfully!" -ForegroundColor Green
        Write-Host "`n📁 Installation Location: $installPath" -ForegroundColor Cyan
        Write-Host "🚀 Quick Access: Type 'IDM_Activation_Pro' in PowerShell" -ForegroundColor Cyan
        Write-Host "📋 Desktop: IDM Activation Pro shortcut created" -ForegroundColor Cyan
        
        # Launch setup wizard
        if (-not $Silent) {
            Write-Host "`nLaunching setup wizard..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            & "$installPath\setup.ps1"
        }
        
    } catch {
        Write-Host "`n[ERROR] Installation failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Main installation execution
if ($MyInvocation.InvocationName -ne '.') {
    Install-IDMPro @PSBoundParameters
}
