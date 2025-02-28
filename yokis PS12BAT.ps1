# PowerShell to Batch Converter - PS12BAT
# Copyright (C) 2024 Froki
# Authored by Noxi-Hu

# Set error and progress preferences
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# Download and display banner
try {
    Invoke-WebRequest 'https://raw.githubusercontent.com/Rako4/yokibanner/refs/heads/main/yokibanner.ps1' -OutFile "$env:temp\nvbanner.ps1"
    . "$env:temp\nvbanner.ps1"
} catch {
    Write-Host "Failed to download or display banner." -ForegroundColor Red
}

# Set execution policy and console appearance
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.WindowTitle = "Froki's PS12BAT Converter"
Clear-Host

# Logging function
function Log {
    param (
        [string]$HighlightMessage,
        [string]$Message,
        [string]$More,
        [ConsoleColor]$TimeColor = 'DarkGray',
        [ConsoleColor]$HighlightColor = 'White',
        [ConsoleColor]$MessageColor = 'White',
        [ConsoleColor]$MoreColor = 'White'
    )
    $time = " [{0:HH:mm:ss}]" -f (Get-Date)
    Write-Host -ForegroundColor $TimeColor $time -NoNewline
    Write-Host -NoNewline " "
    Write-Host -ForegroundColor $HighlightColor $HighlightMessage -NoNewline
    Write-Host -ForegroundColor $MessageColor " $Message" -NoNewline
    Write-Host -ForegroundColor $MoreColor " $More"
}

# Batch file template
$batchTemplate = @'
@echo off
setlocal enabledelayedexpansion
:: Created with Froki's PS12BAT Converter
:: All Rights Reserved © Froki
powershell -ExecutionPolicy Bypass -Command "iex ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('::Base64Payload::')))"
endlocal
exit /b
'@

# Main function
function Main {
    try {
        # Display banner
        BannerCyan

        # Prompt for PS1 file path
        Log "[?]" "Location of the PS1 file" "(Drag/Write)" -HighlightColor Blue -MoreColor DarkGray
        Write-Host " >> " -ForegroundColor Blue -NoNewline
        $path = Read-Host
        $path = $path.Trim('"')

        # Validate input
        if (-not $path) {
            Log "[!]" "No input provided" -HighlightColor Red
            return
        }

        # Check if file exists
        if (Test-Path $path) {
            Log "[+]" "File found at location" -HighlightColor Green
            Start-Sleep -Milliseconds 100
        } else {
            Log "[!]" "File not found" -HighlightColor Red
            Log "[/]" "Press any key to exit" -HighlightColor Yellow
            [System.Console]::ReadKey() > $null
            return
        }

        # Read and encode the PS1 file
        Log "[~]" "Reading PS script" -HighlightColor Gray
        $code = Get-Content $path -Raw

        Log "[~]" "Encoding script to base64" -HighlightColor Gray
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($code)
        $encode = [System.Convert]::ToBase64String($bytes)

        # Prepare batch file
        Log "[~]" "Preparing batch file with embedded base64 payload" -HighlightColor Gray
        $content = $batchTemplate -replace '::Base64Payload::', $encode
        $out = Join-Path -Path (Split-Path -Path $path -Parent) -ChildPath ("FK-" + [System.IO.Path]::GetFileNameWithoutExtension($path) + ".bat")

        # Overwrite if file exists
        if (Test-Path $out) {
            Log "[#]" "File already exists, overwriting it" -HighlightColor Yellow
            Start-Sleep -Milliseconds 100
        }

        # Write batch file
        Log "[~]" "Writing batch file" -HighlightColor Gray
        Set-Content -Path $out -Value $content -Force

        Log "[+]" "Batch file created successfully" -HighlightColor Green
        Start-Sleep -Milliseconds 100

        # Exit
        Log "[/]" "Press any key to exit" -HighlightColor Yellow
        [System.Console]::ReadKey() > $null
    } catch {
        Log "[!]" "Failed:" $_.Exception.Message -HighlightColor Red
    }
}

# Run the main function
Main