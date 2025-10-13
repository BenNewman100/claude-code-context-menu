<#
Copyright (c) 2025 Ben Newman

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

.SYNOPSIS
    Adds a context menu item to open Claude Code in Windows Terminal.

.DESCRIPTION
    This script adds a "Open Claude Code Here" option to the Windows Explorer context menu
    for directories. When clicked, it opens Windows Terminal with PowerShell and runs
    Claude Code in the selected directory.

.PARAMETER Action
    Specifies whether to Install or Uninstall the context menu item.
    Valid values: "Install", "Uninstall"

.EXAMPLE
    .\ClaudeCodeContextMenu-Installer.ps1 -Action Install
    Installs the context menu item.

.EXAMPLE
    .\ClaudeCodeContextMenu-Installer.ps1 -Action Uninstall
    Removes the context menu item.
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Install", "Uninstall")]
    [string]$Action = "Install"
)

# ============================================
# Configuration Variables
# ============================================

# The text that will appear in the context menu
$MenuText = "Open Claude Code Here"

# The internal registry key name for this menu item (no spaces)
$MenuCommand = "ClaudeCode"

# ============================================
# Auto-detect Claude Code Icon
# ============================================
# This section attempts to automatically find the Claude Code executable
# and use its icon for the context menu item

function Get-ClaudeCodeIcon {
    <#
    .SYNOPSIS
        Attempts to find the Claude Code executable and return its path for use as an icon.

    .DESCRIPTION
        Searches common installation locations and the PATH environment variable
        to locate the claude.exe executable. Returns the full path to the executable
        which can be used as an icon source in Windows.

    .OUTPUTS
        String - The full path to claude.exe if found, empty string otherwise.
    #>

    # Try to find claude in the PATH
    $claudePath = (Get-Command claude -ErrorAction SilentlyContinue).Source

    # Only use the path if it's an executable (.exe), not a PowerShell script (.ps1)
    if ($claudePath -and (Test-Path $claudePath) -and $claudePath -match '\.exe$') {
        Write-Host "  Found Claude Code at: $claudePath" -ForegroundColor Green
        return $claudePath
    }

    # Common installation locations to check
    $commonPaths = @(
        "$env:LOCALAPPDATA\Programs\claude\claude.exe",
        "$env:PROGRAMFILES\claude\claude.exe",
        "$env:PROGRAMFILES(x86)\claude\claude.exe",
        "$env:USERPROFILE\.claude\claude.exe"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            Write-Host "  Found Claude Code at: $path" -ForegroundColor Green
            return $path
        }
    }

    Write-Host "  Could not auto-detect Claude Code icon. Using default." -ForegroundColor Yellow
    return ""
}

# Automatically detect and set the icon path to the Claude Code executable
# The executable itself contains an icon that Windows can use
# First, try to use the icon file included with this script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BundledIcon = Join-Path $ScriptDir "claude-code.ico"

if (Test-Path $BundledIcon) {
    $IconPath = $BundledIcon
    Write-Host "  Using bundled Claude Code icon" -ForegroundColor Green
} else {
    # If bundled icon doesn't exist, try to find Claude executable
    $IconPath = Get-ClaudeCodeIcon
}

# ============================================
# Registry Paths
# ============================================
# These paths define where the context menu entries are stored in the Windows Registry
# Using HKCU (HKEY_CURRENT_USER) means no administrator privileges are required

# Path for the menu item when right-clicking ON a directory/folder
$DirectoryShellPath = "HKCU:\Software\Classes\Directory\shell\$MenuCommand"
# Path for the command that executes when clicking the menu item (for directory)
$DirectoryCommandPath = "HKCU:\Software\Classes\Directory\shell\$MenuCommand\command"

# Path for the menu item when right-clicking INSIDE a directory (on the background)
$BackgroundShellPath = "HKCU:\Software\Classes\Directory\Background\shell\$MenuCommand"
# Path for the command that executes when clicking the menu item (for background)
$BackgroundCommandPath = "HKCU:\Software\Classes\Directory\Background\shell\$MenuCommand\command"

function Install-ClaudeCodeContextMenu {
    <#
    .SYNOPSIS
        Installs the Claude Code context menu item by creating necessary registry entries.

    .DESCRIPTION
        This function creates two sets of registry entries:
        1. For right-clicking ON a folder/directory
        2. For right-clicking INSIDE a folder (on the background/empty space)

        Each entry includes the menu text and the command to execute when clicked.
    #>

    Write-Host "Installing Claude Code context menu item..." -ForegroundColor Cyan

    try {
        # ============================================
        # PART 1: Setup for right-clicking ON a directory
        # ============================================

        # Create the main registry key for the context menu item
        # This key represents the menu entry itself
        if (-not (Test-Path $DirectoryShellPath)) {
            New-Item -Path $DirectoryShellPath -Force | Out-Null
            Write-Host "  Created registry key: $DirectoryShellPath" -ForegroundColor Green
        }

        # Set the default value of the key to the text that appears in the menu
        # The "(Default)" property is what Windows displays to the user
        Set-ItemProperty -Path $DirectoryShellPath -Name "(Default)" -Value $MenuText

        # Set an optional icon for the menu item
        # If an icon path is provided and the file exists, set it as the menu icon
        # The ",0" tells Windows to use the first icon resource in the file
        if ($IconPath -and (Test-Path $IconPath)) {
            Set-ItemProperty -Path $DirectoryShellPath -Name "Icon" -Value "$IconPath,0"
        }

        # Create the "command" subkey which holds the actual command to execute
        # This is a required child key under the shell entry
        if (-not (Test-Path $DirectoryCommandPath)) {
            New-Item -Path $DirectoryCommandPath -Force | Out-Null
            Write-Host "  Created registry key: $DirectoryCommandPath" -ForegroundColor Green
        }

        # Set the command that will be executed when the menu item is clicked
        # Breakdown of the command:
        #   wt.exe              = Windows Terminal executable
        #   -d "%V"             = Set the starting directory to %V (the selected folder path)
        #   powershell          = Launch PowerShell
        #   -NoExit             = Keep the window open after running the command
        #   -Command "claude"   = Run the 'claude' command
        # Note: %V is a special variable that Windows Explorer replaces with the selected path
        $command = 'wt.exe -d "%V" powershell -NoExit -Command "claude"'
        Set-ItemProperty -Path $DirectoryCommandPath -Name "(Default)" -Value $command

        # ============================================
        # PART 2: Setup for right-clicking INSIDE a directory (background)
        # ============================================

        # This section does the same as above, but for the "Background" context
        # The background context menu appears when you right-click on empty space inside a folder

        # Create the main registry key for the background context menu item
        if (-not (Test-Path $BackgroundShellPath)) {
            New-Item -Path $BackgroundShellPath -Force | Out-Null
            Write-Host "  Created registry key: $BackgroundShellPath" -ForegroundColor Green
        }

        # Set the menu text for background right-click
        Set-ItemProperty -Path $BackgroundShellPath -Name "(Default)" -Value $MenuText

        # Set the icon for background context menu (if provided)
        # The ",0" tells Windows to use the first icon resource in the file
        if ($IconPath -and (Test-Path $IconPath)) {
            Set-ItemProperty -Path $BackgroundShellPath -Name "Icon" -Value "$IconPath,0"
        }

        # Create the command subkey for background context menu
        if (-not (Test-Path $BackgroundCommandPath)) {
            New-Item -Path $BackgroundCommandPath -Force | Out-Null
            Write-Host "  Created registry key: $BackgroundCommandPath" -ForegroundColor Green
        }

        # Set the same command for background context menu
        # %V will be replaced with the current folder's path when right-clicking inside it
        Set-ItemProperty -Path $BackgroundCommandPath -Name "(Default)" -Value $command

        # ============================================
        # Installation complete
        # ============================================
        Write-Host "`nSuccess! Context menu item installed." -ForegroundColor Green
        Write-Host "Right-click on any folder or inside a folder to see 'Open Claude Code Here' option." -ForegroundColor Yellow

    } catch {
        # Catch any errors during installation and display them
        Write-Host "`nError installing context menu item: $_" -ForegroundColor Red
        exit 1
    }
}

function Uninstall-ClaudeCodeContextMenu {
    <#
    .SYNOPSIS
        Removes the Claude Code context menu item by deleting registry entries.

    .DESCRIPTION
        This function removes both registry entries:
        1. The entry for right-clicking ON a folder
        2. The entry for right-clicking INSIDE a folder (background)
    #>

    Write-Host "Uninstalling Claude Code context menu item..." -ForegroundColor Cyan

    try {
        # ============================================
        # Remove the directory right-click entry
        # ============================================
        # Check if the registry key exists before attempting to remove it
        if (Test-Path $DirectoryShellPath) {
            # Remove the entire key and all its subkeys (like the "command" subkey)
            # -Recurse ensures all child keys are also deleted
            # -Force suppresses confirmation prompts
            Remove-Item -Path $DirectoryShellPath -Recurse -Force
            Write-Host "  Removed registry key: $DirectoryShellPath" -ForegroundColor Green
        } else {
            Write-Host "  Registry key not found: $DirectoryShellPath" -ForegroundColor Yellow
        }

        # ============================================
        # Remove the directory background right-click entry
        # ============================================
        # Same process as above, but for the background context menu
        if (Test-Path $BackgroundShellPath) {
            Remove-Item -Path $BackgroundShellPath -Recurse -Force
            Write-Host "  Removed registry key: $BackgroundShellPath" -ForegroundColor Green
        } else {
            Write-Host "  Registry key not found: $BackgroundShellPath" -ForegroundColor Yellow
        }

        # ============================================
        # Uninstallation complete
        # ============================================
        Write-Host "`nSuccess! Context menu item uninstalled." -ForegroundColor Green

    } catch {
        # Catch any errors during uninstallation and display them
        Write-Host "`nError uninstalling context menu item: $_" -ForegroundColor Red
        exit 1
    }
}

# ============================================
# Main Execution
# ============================================
# This section runs when the script is executed
# It displays a header and calls the appropriate function based on the -Action parameter

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Claude Code Context Menu Setup" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Switch statement to determine which action to perform
# The $Action parameter (Install or Uninstall) determines which function is called
switch ($Action) {
    "Install" {
        Install-ClaudeCodeContextMenu
    }
    "Uninstall" {
        Uninstall-ClaudeCodeContextMenu
    }
}

# ============================================
# Post-installation notes
# ============================================
# Inform the user that Windows Explorer may need to be restarted
# This is necessary because Explorer caches context menu items
Write-Host "`nNote: You may need to restart Windows Explorer for changes to take effect." -ForegroundColor Cyan
Write-Host "You can do this by running: Stop-Process -Name explorer -Force`n" -ForegroundColor Cyan
