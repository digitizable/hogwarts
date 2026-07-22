#Requires -Version 5.1
<#
.SYNOPSIS
  Start elevated input provider without UAC (uses scheduled task).
#>
param([string]$TaskName = "HogwartsInputProvider")

$ErrorActionPreference = "Stop"
$exists = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if (-not $exists) {
    Write-Host "Task '$TaskName' not found. Run install-input-provider-task.ps1 elevated once."
    exit 1
}
Start-ScheduledTask -TaskName $TaskName
Write-Host "Started $TaskName (Highest IL). Pipe \\.\pipe\hogwarts-input should accept agent connections."
