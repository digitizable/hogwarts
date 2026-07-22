#Requires -Version 5.1
<#
.SYNOPSIS
  One-time install: Hogwarts input provider as Highest scheduled task.

.DESCRIPTION
  After one elevated install, daily start via start-input-provider-silent.ps1
  does not show UAC. Medium agent connects to \\.\pipe\hogwarts-input.

.PARAMETER TaskName
  Default HogwartsInputProvider

.PARAMETER AtLogon
  Also start at user logon
#>
param(
    [string]$TaskName = "HogwartsInputProvider",
    [string]$PipeName = "hogwarts-input",
    [switch]$AtLogon
)

$ErrorActionPreference = "Stop"

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "Run elevated PowerShell ONCE (Run as administrator)."
    Write-Host "After install: .\start-input-provider-silent.ps1 (no daily UAC)."
    exit 1
}

$here = $PSScriptRoot
$script = Join-Path $here "HogwartsInputProvider.ps1"
if (-not (Test-Path $script)) { throw "missing $script" }

$ps = (Get-Command powershell.exe).Source
$arg = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`" -PipeName `"$PipeName`""
$action = New-ScheduledTaskAction -Execute $ps -Argument $arg -WorkingDirectory $here
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
if ($AtLogon) {
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    Register-ScheduledTask -TaskName $TaskName -Action $action -Principal $principal -Settings $settings -Trigger $trigger | Out-Null
} else {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Principal $principal -Settings $settings | Out-Null
}

Write-Host "Installed task '$TaskName' (Highest). Pipe: \\.\pipe\$PipeName"
Write-Host "Start now:  schtasks /Run /TN `"$TaskName`""
Write-Host "Or:         .\start-input-provider-silent.ps1"
Write-Host ""
Write-Host "agent.json snippet:"
Write-Host @"
  "input_provider": {
    "enabled": true,
    "kind": "pipe",
    "pipe": "\\\\.\\pipe\\$PipeName"
  }
"@
