# Claude Code Context Menu

A PowerShell script that adds a convenient "Open Claude Code Here" context menu item to Windows Explorer. This allows you to quickly open [Claude Code](https://claude.ai/claude-code) in any directory with just a right-click.

## Features

- **Dual Context Menu Support**: Works when right-clicking both ON a folder and INSIDE a folder (on the background)
- **Automatic Icon Detection**: Automatically finds and uses the Claude Code executable icon
- **No Admin Rights Required**: Uses HKEY_CURRENT_USER registry keys
- **Easy Installation/Uninstallation**: Simple command-line parameters to install or remove
- **Windows Terminal Integration**: Opens Claude Code in Windows Terminal with PowerShell

## Prerequisites

- Windows 10 or later
- [Windows Terminal](https://aka.ms/terminal) installed
- [Claude Code](https://claude.ai/claude-code) installed and available in PATH
- PowerShell 5.1 or later

## Installation

1. Download `ClaudeCodeContextMenu-Installer.ps1`
2. Open PowerShell
3. Navigate to the directory containing the script
4. Run the installation command:

```powershell
.\ClaudeCodeContextMenu-Installer.ps1 -Action Install
```

5. (Optional) Restart Windows Explorer to see changes immediately:

```powershell
Stop-Process -Name explorer -Force
```

## Usage

After installation, you can:

1. **Right-click on any folder** in Windows Explorer
2. Select **"Open Claude Code Here"** from the context menu
3. Windows Terminal will open with PowerShell in that directory, and Claude Code will start automatically

You can also right-click on empty space inside a folder to open Claude Code in the current directory.

## Uninstallation

To remove the context menu item:

```powershell
.\ClaudeCodeContextMenu-Installer.ps1 -Action Uninstall
```

## How It Works

The script modifies Windows Registry to add context menu entries at:

- `HKEY_CURRENT_USER\Software\Classes\Directory\shell\ClaudeCode` (for folder right-click)
- `HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\ClaudeCode` (for background right-click)

When clicked, it executes:
```
wt.exe -p PowerShell -d "%V" claude
```

Where:
- `wt.exe` = Windows Terminal
- `-p PowerShell` = Use PowerShell profile
- `-d "%V"` = Set directory to the selected folder path
- `claude` = Run Claude Code CLI

## Customization

You can customize the script by editing these variables at the top:

```powershell
# The text that appears in the context menu
$MenuText = "Open Claude Code Here"

# The internal registry key name
$MenuCommand = "ClaudeCode"

# Custom icon path (optional)
# By default, it auto-detects the Claude Code executable icon
$IconPath = "C:\Path\To\Custom\Icon.ico"
```

## Troubleshooting

### Context menu item doesn't appear
- Try restarting Windows Explorer: `Stop-Process -Name explorer -Force`
- Verify the registry keys were created using Registry Editor (regedit)

### Icon doesn't show
- The script will try to auto-detect the Claude Code executable
- If detection fails, you can manually set the `$IconPath` variable in the script

### "claude" command not found
- Ensure Claude Code is installed and available in your PATH
- Test by running `claude --version` in PowerShell

## License

This project is licensed under the Mozilla Public License 2.0 (MPL-2.0). See the [LICENSE](LICENSE) file for details.

The MPL-2.0 is a copyleft license that is easy to comply with. You must make the source code for any of your changes available under MPL-2.0, but you can combine this software with code under other licenses without those files becoming subject to the MPL-2.0.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created by Ben Newman with Claude Code
