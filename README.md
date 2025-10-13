# Claude Code Context Menu

A PowerShell script that adds a convenient "Open Claude Code Here" context menu item to Windows Explorer. This allows you to quickly open [Claude Code](https://claude.ai/claude-code) in any directory with just a right-click.

## Features

- **Dual Context Menu Support**: Works when right-clicking both ON a folder and INSIDE a folder (on the background)
- **Automatic Icon Detection**: Automatically finds and uses the Claude Code executable icon
- **No Admin Rights Required**: Uses HKEY_CURRENT_USER registry keys
- **Easy Installation/Uninstallation**: Simple command-line parameters to install or remove
- **Universal Path Detection**: Automatically locates Claude Code and PowerShell without requiring PATH configuration
- **Interactive or Silent Mode**: Choose to be prompted for Explorer restart or run silently

## Prerequisites

- Windows 10 or later
- [Claude Code](https://claude.ai/claude-code) installed via npm
- PowerShell 5.1 or later (included with Windows)

## Installation

1. Download `ClaudeCodeContextMenu-Installer.ps1`
2. Open PowerShell
3. Navigate to the directory containing the script
4. Run the installation command:

```powershell
# Interactive mode (prompts to restart Explorer)
.\ClaudeCodeContextMenu-Installer.ps1 -Action Install

# Silent mode (automatically restarts Explorer)
.\ClaudeCodeContextMenu-Installer.ps1 -Action Install -Silent
```

The script will prompt you to restart Windows Explorer unless you use the `-Silent` flag.

## Usage

After installation, you can:

1. **Right-click on any folder** in Windows Explorer
2. Select **"Open Claude Code Here"** from the context menu
3. PowerShell will open in that directory, and Claude Code will start automatically

You can also right-click on empty space inside a folder to open Claude Code in the current directory.

## Uninstallation

To remove the context menu item:

```powershell
# Interactive mode (prompts to restart Explorer)
.\ClaudeCodeContextMenu-Installer.ps1 -Action Uninstall

# Silent mode (automatically restarts Explorer)
.\ClaudeCodeContextMenu-Installer.ps1 -Action Uninstall -Silent
```

## How It Works

The script modifies Windows Registry to add context menu entries at:

- `HKEY_CURRENT_USER\Software\Classes\Directory\shell\ClaudeCode` (for folder right-click)
- `HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\ClaudeCode` (for background right-click)

When clicked, it executes:
```
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoExit -Command "Set-Location -LiteralPath '%V'; $claudePath = Join-Path $env:APPDATA 'npm\claude.cmd'; & $claudePath"
```

Where:
- Full path to `powershell.exe` is used to avoid PATH issues
- `-NoExit` keeps the window open after running
- `Set-Location -LiteralPath '%V'` changes to the selected folder
- `$env:APPDATA\npm\claude.cmd` automatically locates Claude Code for any user
- `%V` is replaced by Windows with the selected folder path

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
- Restart Windows Explorer using the `-Silent` flag during installation
- Or manually restart: `Stop-Process -Name explorer -Force`
- Verify the registry keys were created using Registry Editor (regedit)

### Icon doesn't show
- The script will try to auto-detect the Claude Code executable
- Place a `claude-code.ico` file in the same directory as the installer script
- The script will use the bundled icon if found

### Error: "The system cannot find the file specified"
- Ensure Claude Code is installed via npm: `npm install -g @anthropic-ai/claude-code`
- The script automatically looks for claude.cmd in `%APPDATA%\npm\`
- If installed elsewhere, the script may need customization

## License

This project is licensed under the Mozilla Public License 2.0 (MPL-2.0). See the [LICENSE](LICENSE) file for details.

The MPL-2.0 is a copyleft license that is easy to comply with. You must make the source code for any of your changes available under MPL-2.0, but you can combine this software with code under other licenses without those files becoming subject to the MPL-2.0.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created by Ben Newman with Claude Code
