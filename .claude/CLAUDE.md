# Claude Code Context Menu - Project Instructions

## Project Overview
**Name:** claude-code-context-menu
**Version:** v0.1.0
**Type:** PowerShell Script
**Description:** Windows Explorer context menu integration for Claude Code

This project provides a PowerShell installer script that adds an "Open Claude Code Here" context menu item to Windows Explorer, allowing users to quickly launch Claude Code in any directory with a right-click.

## Technology Stack
- **Primary Language:** PowerShell 5.1+
- **Platform:** Windows 10 or later
- **Integration:** Windows Registry (HKEY_CURRENT_USER)
- **Dependencies:**
  - Claude Code (installed via npm)
  - Windows PowerShell
  - Windows Terminal (optional, for better UX)

## Key Files
- `ClaudeCodeContextMenu-Installer.ps1` - Main installer/uninstaller script
- `claude-code.ico` - Icon file for context menu (included in repo and used by default). If removed, the script will attempt to locate and extract the icon from the Claude Code executable.
- `README.md` - User documentation
- `LICENSE` - MPL-2.0 license
- `.claude/CLAUDE.md` - Project instructions for Claude Code

## Important Technical Details

### Registry Keys Modified
The installer creates/modifies these registry paths:
- `HKEY_CURRENT_USER\Software\Classes\Directory\shell\ClaudeCode` - Right-click on folders
- `HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\ClaudeCode` - Right-click inside folders

### Key Paths and Variables
- Claude Code location: `$env:APPDATA\npm\claude.cmd` (assumes npm global install)
  - **Note**: The executed command uses this hardcoded path and will fail if Claude is installed elsewhere
  - Icon auto-detection searches multiple paths: PATH, `%LOCALAPPDATA%\Programs\claude\`, `%PROGRAMFILES%\`, and `%USERPROFILE%\.claude\`
- PowerShell executable: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`

### Command Executed by Context Menu
```powershell
powershell.exe -NoExit -Command "Set-Location -LiteralPath '%V'; $claudePath = Join-Path $env:APPDATA 'npm\claude.cmd'; & $claudePath"
```

### Assumptions and Limitations
- Assumes PowerShell 5.1+ (standard on Windows 10+) - no version check performed
- Assumes Claude Code installed via npm to `%APPDATA%\npm\claude.cmd`
- If Claude is installed via other methods (standalone, different package manager), the context menu will fail to launch
- Icon detection is more flexible and searches multiple locations

## PowerShell Coding Conventions for This Project
- Use full PowerShell cmdlet names for clarity (e.g., `Set-Location` not `cd`)
- Use `-LiteralPath` instead of `-Path` for safety with special characters
- Always use `$env:` variables instead of hardcoded paths
- Include error handling with Try/Catch blocks
- Provide verbose output for debugging
- Support both interactive and silent modes via parameters

## Project Constraints
- **No admin rights required** - Must use HKEY_CURRENT_USER only
- **Universal compatibility** - Must work without PATH configuration
- **Automatic detection** - Find Claude Code and icons automatically when possible
- **Clean uninstall** - Must remove all registry entries completely

## Known Limitations
- The context menu command hardcodes the Claude Code path as `%APPDATA%\npm\claude.cmd`
- This only works for npm global installations
- If Claude is installed via other methods (standalone installer, winget, scoop, etc.), the context menu entry will be created but will fail when clicked
- Future improvement: Make the command search for claude.cmd in PATH or common locations at runtime

## License
Mozilla Public License 2.0 (MPL-2.0)
- Copyleft license
- Changes to this code must be shared under MPL-2.0
- Can be combined with code under other licenses

## Testing Considerations
When modifying the installer script, test:
1. Fresh installation on a clean system
2. Uninstallation removes all registry entries
3. Icon detection works with various Claude Code installation methods
4. Silent mode properly restarts Windows Explorer
5. Works with paths containing spaces and special characters
6. Both context menu types work (on folder and inside folder)
