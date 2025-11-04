# Security Features

## Overview

This document details the security features implemented in IDM Activation & Trial Reset Script Pro, including protection mechanisms, privacy features, and security considerations.

## Security Architecture

### Multi-Layer Security Approach

```
┌─────────────────────────────────────┐
│   User Input Validation Layer       │
├─────────────────────────────────────┤
│   AMSI Bypass Layer                 │
├─────────────────────────────────────┤
│   Execution Protection Layer        │
├─────────────────────────────────────┤
│   Evidence Cleanup Layer            │
└─────────────────────────────────────┘
```

## AMSI Bypass Implementation

### What is AMSI?

AMSI (Antimalware Scan Interface) is a Windows security feature that allows antivirus software to scan scripts before execution.

### Bypass Techniques

#### Method 1: Reflection-Based Bypass
```powershell
$amsiContext = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$amsiField = $amsiContext.GetField('amsiInitFailed', 'NonPublic,Static')
$amsiField.SetValue($null, $true)
```

**How it works:**
- Accesses internal AMSI initialization state
- Sets the "failed" flag to true
- Causes AMSI to skip scanning

**Detection risk:** Medium
**Effectiveness:** High on PowerShell 5.1

#### Method 2: Registry Modification
```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\AMSI" `
    -Name "AllowScriptScan" -Value 0
```

**How it works:**
- Modifies AMSI configuration in registry
- Disables script scanning globally
- Requires administrator privileges

**Detection risk:** Low
**Effectiveness:** High on all versions

### AMSI Bypass Safety

- **Temporary**: Changes are session-specific (Method 1)
- **Reversible**: Registry changes can be undone (Method 2)
- **No Malware**: No malicious payload delivery
- **Transparent**: All actions logged

## Windows Defender Management

### Temporary Disable Feature

```powershell
Set-MpPreference -DisableRealtimeMonitoring $true
```

**When used:**
- Aggressive mode (`-Mode Aggressive`)
- Deep clean operations (`-DeepClean`)
- Enterprise deployment (`-Enterprise`)

**Automatic re-enable:**
```powershell
Set-MpPreference -DisableRealtimeMonitoring $false
```

### Safety Mechanisms

1. **Automatic Re-enablement**: Always re-enabled after execution
2. **Error Handling**: Failures don't prevent re-enablement
3. **User Notification**: Logged when disabled/enabled
4. **Time-Limited**: Only disabled during active operations

## String Obfuscation

### Purpose
Prevent static analysis and signature-based detection of sensitive operations.

### Implementation
```powershell
class ObfuscationEngine {
    static [string]Deobfuscate([string]$inputString) {
        $bytes = [System.Convert]::FromBase64String($inputString)
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    }
}
```

### Use Cases
- Sensitive registry paths
- Critical command strings
- License key patterns

## Evidence Cleanup System

### What Gets Cleaned

#### PowerShell History
```powershell
$historyPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\" +
               "PowerShell\PSReadLine\ConsoleHost_history.txt"
Clear-Content -Path $historyPath -Force
```

#### Temporary Files
```powershell
Get-ChildItem -Path $env:TEMP -Filter "IDM_Pro_*" | 
    Remove-Item -Recurse -Force
```

#### PowerShell Session History
```powershell
Clear-History
```

### When Cleanup Occurs

- **Stealth Mode**: Always enabled
- **Enterprise Mode**: Always enabled
- **Normal Mode**: Optional (user choice)

### What's NOT Cleaned

- System event logs (requires admin + special permissions)
- Windows Security logs
- Third-party monitoring tools
- Network traffic logs

## Telemetry Spoofing

### Fake Registration Data

```powershell
Set-ItemProperty -Path $dmPath -Name "FName" -Value "Registered User"
Set-ItemProperty -Path $dmPath -Name "LName" -Value "Pro Edition"
Set-ItemProperty -Path $dmPath -Name "Email" -Value "user@registered.com"
```

### Purpose
- Simulate legitimate registration
- Prevent trial expiration prompts
- Bypass update checks

### No External Communication
- **No network calls**: All operations are local
- **No data transmission**: No information sent anywhere
- **No telemetry**: Script doesn't report usage

## Backup and Recovery

### Automatic Backup Creation

```powershell
$Script:BackupPath = "$env:TEMP\IDM_Pro_Backup_$ExecutionTimestamp"
```

### What's Backed Up

1. **Registry Keys**: All IDM-related registry entries
2. **Configuration Files**: License files, settings
3. **User Data**: Download history, preferences

### Backup Format

```
IDM_Pro_Backup_20240115_143045/
├── Registry/
│   ├── HKCU_Software_DownloadManager.reg
│   └── HKLM_SOFTWARE_Tonec_Inc.reg
└── Files/
    ├── idm_gr.sys
    └── idm_licence.key
```

### Recovery Process

Manual recovery if needed:
1. Navigate to backup folder
2. Import .reg files (double-click)
3. Copy files back to original locations
4. Restart IDM

## Privilege Management

### Administrator Check

```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

### Operations Requiring Admin

- Windows Defender modification
- HKLM registry modifications
- System-wide AMSI changes
- Protected file operations

### Graceful Degradation

If not running as admin:
- Warning displayed
- User can choose to continue
- Some operations may fail
- Errors logged but not fatal

## Logging and Auditing

### Security Event Logging

```powershell
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    $Script:OperationLog += $logEntry
}
```

### Log Security

- **Timestamps**: All actions timestamped
- **Levels**: Severity classification
- **Context**: Full operation context
- **Persistence**: Saved to file (unless stealth mode)

### Sensitive Data Handling

- **No passwords logged**: License keys obfuscated
- **No personal data**: User information not collected
- **Local only**: Logs never transmitted

## Network Security

### No External Connections

The script makes **ZERO** network connections:
- No update checks
- No telemetry reporting
- No license validation servers
- No analytics tracking

### Verification

```powershell
# No network code in entire script
# Can be verified by reviewing source code
# Can be tested with network monitoring tools
```

## Code Signing

### Current Status
- Script is not code-signed (open source)
- Users should review code before execution
- Execution policy may need adjustment

### Recommended Execution

```powershell
# Review script first
Get-Content .\IDM_Activation_Pro.ps1 | Select-String "Invoke-WebRequest|Net.WebClient"

# Execute with bypass (after review)
powershell -ExecutionPolicy Bypass -File .\IDM_Activation_Pro.ps1
```

## Security Best Practices

### For Users

1. **Review Code**: Always review scripts before execution
2. **Test Environment**: Test in VM or isolated system first
3. **Backup**: Ensure backups are created
4. **Administrator**: Run as admin for full functionality
5. **Antivirus**: Temporarily disable if needed, re-enable after

### For Administrators

1. **Controlled Deployment**: Use enterprise mode
2. **Silent Execution**: Use `-Silent` for automation
3. **Logging**: Review logs after deployment
4. **Testing**: Test on pilot systems first
5. **Documentation**: Document deployment procedures

## Threat Model

### What This Script Protects Against

- ✅ Static analysis detection
- ✅ Signature-based antivirus detection
- ✅ Execution trail discovery
- ✅ Registry forensics

### What This Script Does NOT Protect Against

- ❌ Behavioral analysis (advanced AV)
- ❌ Memory forensics
- ❌ Network monitoring (not applicable)
- ❌ Kernel-level security

## Compliance Considerations

### Legal Use Only

This script is for:
- ✅ Educational purposes
- ✅ Personal testing environments
- ✅ Research and development
- ✅ Backup/recovery scenarios

This script is NOT for:
- ❌ Bypassing legitimate software licenses
- ❌ Commercial piracy
- ❌ Unauthorized system access
- ❌ Malicious purposes

### Ethical Guidelines

1. **Respect Licensing**: Purchase legitimate software
2. **Personal Use**: Use for learning and testing only
3. **No Distribution**: Don't distribute activated software
4. **Support Developers**: Support software creators

## Security Disclosure

### Reporting Security Issues

If you find a security vulnerability:

1. **Do NOT** open a public issue
2. Email: security@example.com
3. Include:
   - Vulnerability description
   - Reproduction steps
   - Potential impact
   - Suggested fix (optional)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 72 hours
- **Fix Development**: Within 30 days
- **Public Disclosure**: After fix release

## Security Updates

### Version History

- **v2.1.0**: Enhanced AMSI bypass, evidence cleanup
- **v2.0.0**: Added obfuscation, improved security
- **v1.0.0**: Basic functionality

### Update Recommendations

- Check for updates monthly
- Review changelog for security fixes
- Test updates in isolated environment
- Deploy updates during maintenance windows

## Conclusion

This script implements multiple security layers to:
1. Protect user privacy
2. Prevent detection
3. Enable safe testing
4. Provide transparency

**Remember**: Use responsibly and ethically. Always comply with software licenses and local laws.
