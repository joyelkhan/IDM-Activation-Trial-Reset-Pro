# IDM Activation & Trial Reset Script Pro 🚀

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+%20%7C%207.0+-5391FE?style=for-the-badge&logo=powershell)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![GitHub Issues](https://img.shields.io/github/issues/yourusername/IDM-Activation-Trial-Reset-Pro?style=for-the-badge)](https://github.com/yourusername/IDM-Activation-Trial-Reset-Pro/issues)

> **Professional-grade PowerShell solution for managing Internet Download Manager licensing with enterprise features**

---

## ⚡ Features

- 🛡️ **Advanced Security Bypass** - AMSI evasion and Defender exclusion techniques
- 🔄 **Comprehensive Trial Reset** - Complete registry and filesystem cleaning
- 🎯 **Smart Detection** - Multi-layered IDM installation detection
- 📊 **Enterprise Logging** - Detailed execution logs and system reports
- 🚀 **Silent Deployment** - Enterprise-ready quiet execution modes
- 🔒 **Evidence Cleanup** - Automatic execution trail removal
- 🌐 **Telemetry Spoofing** - Fake registration and update check simulation

## 📋 Prerequisites

- **Windows 10/11** (x64/x86)
- **PowerShell 5.1+** (Windows PowerShell) or **PowerShell 7.0+**
- **Administrative Privileges** (Required for system modifications)
- **Internet Download Manager** (Installed on system)

## 🚀 Quick Start

### Method 1: Standard Execution
```powershell
# Download and execute directly
irm https://raw.githubusercontent.com/yourusername/IDM-Activation-Trial-Reset-Pro/main/IDM_Activation_Pro.ps1 | iex
```

### Method 2: Manual Download

```powershell
# Clone repository
git clone https://github.com/yourusername/IDM-Activation-Trial-Reset-Pro.git
cd IDM-Activation-Trial-Reset-Pro

# Execute main script
.\IDM_Activation_Pro.ps1
```

### Method 3: Enterprise Deployment

```powershell
# Silent enterprise deployment
.\IDM_Activation_Pro.ps1 -Enterprise -Silent

# Custom trial extension (30 days default)
.\IDM_Activation_Pro.ps1 -TrialExtensionDays 45 -Silent
```

## 🛠️ Usage Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| -ForceBypass | Skip confirmation prompts | $false |
| -ResetOnly | Only reset trial, no activation | $false |
| -StealthMode | Enable stealth operations | $false |
| -DeepClean | Aggressive system cleaning | $false |
| -Enterprise | Enterprise deployment mode | $false |
| -Silent | No console output | $false |
| -TrialExtensionDays | Days to extend trial | 30 |
| -Mode | Execution mode (Normal/Aggressive/Stealth) | Normal |

## 🔧 Advanced Usage

### Custom License Key

```powershell
.\IDM_Activation_Pro.ps1 -CustomLicenseKey "YOUR_CUSTOM_LICENSE_KEY"
```

### Aggressive Mode

```powershell
.\IDM_Activation_Pro.ps1 -Mode Aggressive -DeepClean -ForceBypass
```

### Stealth Operations

```powershell
.\IDM_Activation_Pro.ps1 -StealthMode -Silent -Enterprise
```

## 📁 Project Structure

```
IDM-Activation-Trial-Reset-Pro/
├── 📄 IDM_Activation_Pro.ps1          # Main activation script
├── 📄 LICENSE                         # MIT License
├── 📄 SECURITY.md                     # Security policy
├── 📄 CONTRIBUTING.md                 # Contribution guidelines
├── 📄 CHANGELOG.md                    # Version history
├── 📁 docs/                           # Documentation
│   ├── 🔧 Technical_Details.md
│   ├── 🛡️ Security_Features.md
│   └── 🔍 Comparison_Analysis.md
└── 📁 examples/                       # Usage examples
    ├── 🏢 Enterprise_Deployment.ps1
    └── 🔄 Scheduled_Reset.ps1
```

## 🛡️ Security Features

- **AMSI Bypass**: Multiple technique implementation
- **Defender Exclusion**: Temporary real-time monitoring disable
- **String Obfuscation**: Critical command encryption
- **Evidence Cleanup**: PowerShell history and log removal
- **Telemetry Spoofing**: Fake registration communications

## ⚠️ Disclaimer

This project is intended for **educational and research purposes only**. Users are responsible for complying with software licensing agreements and local laws. The developers are not liable for any misuse or damage caused by this software.

**Supported IDM Versions**: 6.4x and newer

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Reporting Issues

Found a bug? Please [open an issue](https://github.com/yourusername/IDM-Activation-Trial-Reset-Pro/issues/new?template=bug_report.md) with:

- Detailed description
- Steps to reproduce
- System information
- Error logs

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/IDM-Activation-Trial-Reset-Pro&type=Date)](https://star-history.com/#yourusername/IDM-Activation-Trial-Reset-Pro&Date)

---

<div align="center">

**Made with ❤️ for the PowerShell community**

*For educational purposes only - Support software developers by purchasing legitimate licenses*

</div>
