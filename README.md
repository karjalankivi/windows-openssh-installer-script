# OpenSSH Server Automated Installer for Windows (PowerShell)

This PowerShell script automates the installation and setup of the **OpenSSH Server** on Windows systems.

---

## 🚀 What does it do?

- Attempts to download the OpenSSH installer from the official GitHub repository.
- If the download fails, it **requires** a locally downloaded installer from the official source to proceed securely.
- Installs and configures the OpenSSH server silently.
- Configures firewall rules for SSH access (port 22).
- Sets permissions and service startup type automatically.
- Performs checks to verify successful installation and operational status.

---

## 🔧 How to use:

1. **Download the script** to your Windows machine.

2. **Security note:**  
   For enhanced security and reliability, manually download the OpenSSH MSI installer from the official GitHub repository:
   - [OpenSSH Releases](https://github.com/powershell/win32-openssh/releases)
   - Verify that the downloaded file exactly matches the filename and version specified in the script (`OpenSSH-Win64-v9.5.0.0.msi`) Or edit it.

3. **Place the downloaded installer** (`OpenSSH-Win64-v9.5.0.0.msi`) in the **same directory** as this script.

4. **Run PowerShell as Administrator**:
   - Right-click on "PowerShell" → "Run as Administrator".

5. Navigate to the script directory and execute:
   ```powershell
   .\openssh-server-auto-install-windows.ps1
