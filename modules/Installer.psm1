<#
.SYNOPSIS
    Installation module for IDM Activation Pro
.DESCRIPTION
    Professional installation engine with branding and system validation
.AUTHOR
    MD. Abu Naser Khan
.VERSION
    2.2.0
#>

class ProfessionalInstaller {
    [string]$Author = "MD. Abu Naser Khan"
    [string]$Version = "2.2.0"
    [string]$ProjectName = "IDM Activation Pro"
    [string]$InstallPath
    [hashtable]$SystemInfo
    
    ProfessionalInstaller() {
        $this.InstallPath = "$env:ProgramFiles\IDM Activation Pro"
        $this.SystemInfo = @{}
        $this.GatherSystemInfo()
    }
    
    [void]GatherSystemInfo() {
        $this.SystemInfo = @{
            OS = [System.Environment]::OSVersion.VersionString
            PowerShell = $PSVersionTable.PSVersion.ToString()
            Architecture = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE')
            IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }
    }
    
    [void]ShowBranding() {
        Clear-Host
        Write-Host "`n"
        Write-Host "    ██╗██████╗ ███╗   ███╗    █████╗  ██████╗████████╗██╗██╗   ██╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗" -ForegroundColor Cyan
        Write-Host "    ██║██╔══██╗████╗ ████║   ██╔══██╗██╔════╝╚══██╔══╝██║██║   ██║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║" -ForegroundColor Cyan
        Write-Host "    ██║██║  ██║██╔████╔██║   ███████║██║        ██║   ██║██║   ██║███████║   ██║   ██║██║   ██║██╔██╗ ██║" -ForegroundColor Cyan
        Write-Host "    ██║██║  ██║██║╚██╔╝██║   ██╔══██║██║        ██║   ██║██║   ██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║" -ForegroundColor Cyan
        Write-Host "    ██║██████╔╝██║ ╚═╝ ██║   ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║" -ForegroundColor Cyan
        Write-Host "    ╚═╝╚═════╝ ╚═╝     ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝ ╚═══╝" -ForegroundColor Cyan
        Write-Host "`n"
        Write-Host "                                           Version $($this.Version)" -ForegroundColor Green
        Write-Host "                                         Author: $($this.Author)" -ForegroundColor Magenta
        Write-Host "`n"
    }
    
    [bool]ValidateSystem() {
        Write-Host "[INSTALLER] Validating system requirements..." -ForegroundColor Cyan
        
        $requirements = @{
            "Windows 10/11" = [Environment]::OSVersion.Version -ge (new-object Version 10,0)
            "PowerShell 5.1+" = $PSVersionTable.PSVersion -ge (new-object Version 5,1)
            "Administrative Rights" = $this.SystemInfo.IsAdmin
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
    
    [void]Install() {
        $this.ShowBranding()
        
        if (-not $this.ValidateSystem()) {
            Write-Host "`n[ERROR] System requirements not met." -ForegroundColor Red
            return
        }
        
        $this.CopyFiles()
        $this.CreateShortcuts()
        $this.UpdateEnvironment()
        $this.ShowCompletion()
    }
    
    [void]CopyFiles() {
        Write-Host "`n[INSTALLER] Copying files..." -ForegroundColor Cyan
        
        if (-not (Test-Path $this.InstallPath)) {
            New-Item -Path $this.InstallPath -ItemType Directory -Force | Out-Null
        }
        
        # Copy main files
        $files = @("IDM_Activation_Pro.ps1", "setup.ps1", "uninstall.ps1", "README.md", "LICENSE")
        foreach ($file in $files) {
            if (Test-Path $file) {
                Copy-Item $file $this.InstallPath -Force
                Write-Host "  ✅ Copied: $file" -ForegroundColor Green
            }
        }
    }
    
    [void]CreateShortcuts() {
        Write-Host "`n[INSTALLER] Creating shortcuts..." -ForegroundColor Cyan
        
        $shortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "IDM Activation Pro.lnk")
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($this.InstallPath)\IDM_Activation_Pro.ps1`""
        $Shortcut.WorkingDirectory = $this.InstallPath
        $Shortcut.Description = "IDM Activation Pro - Professional IDM Management"
        $Shortcut.Save()
        
        Write-Host "  ✅ Desktop shortcut created" -ForegroundColor Green
    }
    
    [void]UpdateEnvironment() {
        Write-Host "`n[INSTALLER] Updating environment..." -ForegroundColor Cyan
        
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notmatch [Regex]::Escape($this.InstallPath)) {
            $newPath = $currentPath + ";" + $this.InstallPath
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-Host "  ✅ Added to system PATH" -ForegroundColor Green
        }
    }
    
    [void]ShowCompletion() {
        Write-Host "`n🎉 Installation Completed Successfully!" -ForegroundColor Green
        Write-Host "`n📁 Installation Location: $($this.InstallPath)" -ForegroundColor Cyan
        Write-Host "🚀 Quick Access: Desktop shortcut created" -ForegroundColor Cyan
        Write-Host "📋 System PATH: Updated" -ForegroundColor Cyan
    }
}

# Export module members
Export-ModuleMember -Function *
