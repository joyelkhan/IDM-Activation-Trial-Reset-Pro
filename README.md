# IDM Activation & Trial Reset Script Pro 🚀

<div align="center">

**Professional PowerShell Solution for Internet Download Manager**

*Developed by **MD. Abu Naser Khan***

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+%20%7C%207.0+-5391FE?style=for-the-badge&logo=powershell)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.2.0-blue?style=for-the-badge)](CHANGELOG.md)
[![Author](https://img.shields.io/badge/Author-MD.%20Abu%20Naser%20Khan-orange?style=for-the-badge)](https://github.com/abunaserkhan)

</div>

---

## ✨ What's New in v2.2

- 🎨 **Professional Branding** - New logo and visual identity
- 🚀 **Smart Installer** - Automated installation process
- 📦 **Project Organization** - Better file structure
- 🔄 **Auto-Exit System** - Clean process termination
- 🛠️ **Setup Wizard** - Guided installation experience
- 📋 **System Validation** - Pre-flight checks and compatibility

## ⚡ Quick Installation

### 🎯 One-Click Install (Recommended)
```powershell
# Run this command for automatic installation
iwr -useb "https://raw.githubusercontent.com/joyelkhan/IDM-Activation-Trial-Reset-Pro/main/install.ps1" | iex
```

### 🔧 Manual Installation
```powershell
# Download and extract manually
git clone https://github.com/joyelkhan/IDM-Activation-Trial-Reset-Pro.git
cd IDM-Activation-Trial-Reset-Pro
.\setup.ps1
```

## 🎨 Features Overview

| Feature | Description | Status |
|---------|-------------|--------|
| 🛡️ Advanced Security | AMSI bypass & Defender exclusion | ✅ |
| 🔄 Smart Trial Reset | Complete registry & file cleanup | ✅ |
| 🚀 Enterprise Ready | Silent deployment modes | ✅ |
| 📊 System Analytics | Comprehensive logging & reports | ✅ |
| 🎯 Professional UI | Beautiful console interface | ✅ |
| 🔒 Auto Cleanup | Evidence removal & process exit | ✅ |

## 🏗️ Project Structure

```
IDM-Activation-Trial-Reset-Pro/
├── 🎯 install.ps1                 # Smart installer
├── 🛠️ setup.ps1                   # Setup wizard
├── 🚀 IDM_Activation_Pro.ps1      # Main application
├── 📄 uninstall.ps1               # Clean removal
├── 📁 assets/                     # Brand assets
│   ├── 🎨 icon.png                # Project logo
│   └── 📱 banner.txt              # ASCII banner
├── 📁 modules/                    # Core modules
│   ├── 🔧 Installer.psm1
│   ├── 🛡️ Security.psm1
│   └── 🎨 Interface.psm1
└── 📁 docs/                       # Documentation
    ├── 📖 user_guide.md
    └── 🔧 technical.md
```

## 📋 Requirements

- **Operating System**: Windows 10/11 (64-bit)
- **PowerShell**: Version 5.1 or higher
- **Privileges**: Administrator rights required
- **IDM**: Internet Download Manager installed

## 🚀 Quick Start

### Basic Usage

```powershell
# Run with default settings
.\IDM_Activation_Pro.ps1

# Silent mode (no user interaction)
.\IDM_Activation_Pro.ps1 -Silent

# Enterprise mode with custom trial period
.\IDM_Activation_Pro.ps1 -Enterprise -TrialDays 60
```

### Advanced Options

```powershell
# Skip security features (not recommended)
.\IDM_Activation_Pro.ps1 -SkipSecurity

# Disable automatic cleanup
.\IDM_Activation_Pro.ps1 -NoCleanup

# Verbose logging
.\IDM_Activation_Pro.ps1 -Verbose
```

## 🔧 Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `-Silent` | Switch | Run without user interaction | False |
| `-Enterprise` | Switch | Enable enterprise features | False |
| `-TrialDays` | Int | Trial extension period (30-365) | 30 |
| `-SkipSecurity` | Switch | Bypass security measures | False |
| `-NoCleanup` | Switch | Disable evidence cleanup | False |
| `-LogPath` | String | Custom log file location | Auto |

## 📖 Documentation

- [User Guide](docs/user_guide.md) - Comprehensive usage instructions
- [Technical Documentation](docs/technical.md) - Architecture and internals
- [Contributing Guide](CONTRIBUTING.md) - Development guidelines

## 👨‍💻 Author

**MD. Abu Naser Khan**  
*PowerShell Developer & System Architect*

- 🌐 GitHub: [abunaserkhan](https://github.com/abunaserkhan)
- 💼 Portfolio: [Professional Profile](AUTHOR.md)
- 📧 Contact: Available through GitHub

## ⚠️ Important Notes

### Legal Disclaimer
This tool is provided for educational and legitimate use cases only. Users are responsible for ensuring compliance with:
- Software licensing agreements
- Local and international laws
- Organizational policies

### Security Considerations
- Always review scripts before execution
- Use in controlled environments
- Maintain proper backups
- Follow security best practices

### Support
This is a community-driven project. For issues or questions:
1. Check existing documentation
2. Search closed issues
3. Open a new issue with details

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 🙏 Acknowledgments

- PowerShell Community
- Security Research Community
- All Contributors

---

<div align="center">

**Made with ❤️ by MD. Abu Naser Khan**

*Support software developers by purchasing legitimate licenses*

**⚠️ Disclaimer**: This tool is for educational purposes. Always respect software licenses and use responsibly.

</div>
