#Requires -Version 5.1
<#
.SYNOPSIS
  High-IL Keepstream input helper — hogwarts-input/1 over a named pipe.

.DESCRIPTION
  Listens on \\.\pipe\hogwarts-input (or -PipeName), reads HELLO + JSON event
  batches from the Medium agent, and injects via user32 SendInput.

  This is NOT a UAC bypass. Run this script elevated once (or via a Highest
  scheduled task installed by install-input-provider-task.ps1) so it can drive
  Task Manager / admin UI. The agent stays Medium and only forwards INPUT.

.PARAMETER PipeName
  Named pipe leaf name (default hogwarts-input).

.PARAMETER Once
  Exit after the first client disconnects (default: re-arm for next Session).
#>
param(
    [string]$PipeName = "hogwarts-input",
    [switch]$Once
)

$ErrorActionPreference = "Stop"

# --- SendInput via C# ---
$sendInputSrc = @"
using System;
using System.Runtime.InteropServices;

public static class HogwartsInject {
  [StructLayout(LayoutKind.Sequential)]
  public struct MOUSEINPUT {
    public int dx, dy;
    public uint mouseData, dwFlags, time;
    public IntPtr dwExtraInfo;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct KEYBDINPUT {
    public ushort wVk, wScan;
    public uint dwFlags, time;
    public IntPtr dwExtraInfo;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct HARDWAREINPUT {
    public uint uMsg;
    public ushort wParamL, wParamH;
  }
  [StructLayout(LayoutKind.Explicit)]
  public struct INPUTUNION {
    [FieldOffset(0)] public MOUSEINPUT mi;
    [FieldOffset(0)] public KEYBDINPUT ki;
    [FieldOffset(0)] public HARDWAREINPUT hi;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct INPUT {
    public uint type;
    public INPUTUNION U;
  }
  [DllImport("user32.dll", SetLastError=true)]
  public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
  [DllImport("user32.dll")]
  public static extern bool SetCursorPos(int X, int Y);
  [DllImport("user32.dll")]
  public static extern short VkKeyScanW(char ch);
  [DllImport("user32.dll")]
  public static extern int GetSystemMetrics(int nIndex);

  const uint INPUT_MOUSE = 0, INPUT_KEYBOARD = 1;
  const uint MOUSEEVENTF_MOVE = 0x0001, MOUSEEVENTF_ABSOLUTE = 0x8000;
  const uint MOUSEEVENTF_LEFTDOWN = 0x0002, MOUSEEVENTF_LEFTUP = 0x0004;
  const uint MOUSEEVENTF_RIGHTDOWN = 0x0008, MOUSEEVENTF_RIGHTUP = 0x0010;
  const uint MOUSEEVENTF_MIDDLEDOWN = 0x0020, MOUSEEVENTF_MIDDLEUP = 0x0040;
  const uint KEYEVENTF_KEYUP = 0x0002;

  static int ScreenW() { return Math.Max(1, GetSystemMetrics(0) - 1); }
  static int ScreenH() { return Math.Max(1, GetSystemMetrics(1) - 1); }

  static void Mouse(uint flags, int? x, int? y) {
    var inp = new INPUT();
    inp.type = INPUT_MOUSE;
    if (x.HasValue && y.HasValue) {
      int sx = ScreenW(), sy = ScreenH();
      int ax = (int)(Math.Max(0, Math.Min(sx, x.Value)) * 65535.0 / sx);
      int ay = (int)(Math.Max(0, Math.Min(sy, y.Value)) * 65535.0 / sy);
      inp.U.mi = new MOUSEINPUT { dx = ax, dy = ay, dwFlags = flags | MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE };
    } else {
      inp.U.mi = new MOUSEINPUT { dwFlags = flags };
    }
    SendInput(1, new[] { inp }, Marshal.SizeOf(typeof(INPUT)));
  }

  static void Key(ushort vk, bool up) {
    var inp = new INPUT();
    inp.type = INPUT_KEYBOARD;
    inp.U.ki = new KEYBDINPUT { wVk = vk, dwFlags = up ? KEYEVENTF_KEYUP : 0 };
    SendInput(1, new[] { inp }, Marshal.SizeOf(typeof(INPUT)));
  }

  public static void ApplyEvent(string type, double? fx, double? fy, int? x, int? y, string button, string key, string text) {
    int? px = null, py = null;
    if (fx.HasValue || fy.HasValue) {
      double fxx = fx ?? 0.5, fyy = fy ?? 0.5;
      if (fxx < 0) fxx = 0; if (fxx > 1) fxx = 1;
      if (fyy < 0) fyy = 0; if (fyy > 1) fyy = 1;
      px = (int)(fxx * ScreenW());
      py = (int)(fyy * ScreenH());
    } else if (x.HasValue || y.HasValue) {
      px = x ?? 0; py = y ?? 0;
    }
    string typ = (type ?? "click").ToLowerInvariant();
    if ((typ == "move" || typ == "click" || typ == "dblclick" || typ == "down" || typ == "up") && px.HasValue && py.HasValue) {
      Mouse(0, px, py);
      SetCursorPos(px.Value, py.Value);
    }
    if (typ == "move") return;
    uint down = MOUSEEVENTF_LEFTDOWN, upf = MOUSEEVENTF_LEFTUP;
    string btn = (button ?? "left").ToLowerInvariant();
    if (btn == "right") { down = MOUSEEVENTF_RIGHTDOWN; upf = MOUSEEVENTF_RIGHTUP; }
    else if (btn == "middle") { down = MOUSEEVENTF_MIDDLEDOWN; upf = MOUSEEVENTF_MIDDLEUP; }
    if (typ == "down") { Mouse(down, null, null); return; }
    if (typ == "up") { Mouse(upf, null, null); return; }
    if (typ == "dblclick") {
      Mouse(down, null, null); Mouse(upf, null, null);
      Mouse(down, null, null); Mouse(upf, null, null);
      return;
    }
    if (typ == "click") { Mouse(down, null, null); Mouse(upf, null, null); return; }
    if (typ == "type" && !string.IsNullOrEmpty(text)) {
      foreach (char ch in text) {
        if (text.Length > 200) break;
        short vk = VkKeyScanW(ch);
        if (vk == -1) continue;
        ushort code = (ushort)(vk & 0xFF);
        bool shift = ((vk >> 8) & 1) != 0;
        if (shift) Key(0x10, false);
        Key(code, false); Key(code, true);
        if (shift) Key(0x10, true);
      }
      return;
    }
    if (typ == "key" && !string.IsNullOrEmpty(key)) {
      string k = key.ToLowerInvariant();
      ushort code = 0;
      switch (k) {
        case "return": case "enter": code = 0x0D; break;
        case "escape": case "esc": code = 0x1B; break;
        case "tab": code = 0x09; break;
        case "backspace": code = 0x08; break;
        case "space": code = 0x20; break;
        case "up": code = 0x26; break;
        case "down": code = 0x28; break;
        case "left": code = 0x25; break;
        case "right": code = 0x27; break;
        case "delete": code = 0x2E; break;
        case "home": code = 0x24; break;
        case "end": code = 0x23; break;
        default:
          if (k.Length == 1) {
            short vk = VkKeyScanW(k[0]);
            if (vk != -1) code = (ushort)(vk & 0xFF);
          }
          break;
      }
      if (code != 0) { Key(code, false); Key(code, true); }
    }
  }
}
"@

try {
    Add-Type -TypeDefinition $sendInputSrc -Language CSharp -ErrorAction Stop | Out-Null
} catch {
    # type may already exist in session
    if ($_.Exception.Message -notmatch "already exists") { throw }
}

function Write-Log([string]$msg) {
    $ts = (Get-Date).ToString("o")
    [Console]::Error.WriteLine("[hogwarts-input] $ts $msg")
}

function Invoke-Events($obj) {
    if ($null -eq $obj) { return 0 }
    $evs = $obj.events
    if ($null -eq $evs) { return 0 }
    $n = 0
    foreach ($ev in $evs) {
        if ($null -eq $ev) { continue }
        $type = [string]$ev.type
        $fx = $null; $fy = $null; $x = $null; $y = $null
        if ($null -ne $ev.fx) { $fx = [double]$ev.fx }
        if ($null -ne $ev.fy) { $fy = [double]$ev.fy }
        if ($null -ne $ev.x) { $x = [int]$ev.x }
        if ($null -ne $ev.y) { $y = [int]$ev.y }
        $button = [string]$ev.button
        $key = [string]$ev.key
        $text = [string]$ev.text
        try {
            [HogwartsInject]::ApplyEvent($type, $fx, $fy, $x, $y, $button, $key, $text)
            $n++
        } catch {
            Write-Log "inject error: $($_.Exception.Message)"
        }
    }
    return $n
}

function Handle-Client([System.IO.Pipes.NamedPipeServerStream]$pipe) {
    # Server is In-only: read HELLO + event lines; HELLO_OK is optional for agents.
    $reader = New-Object System.IO.StreamReader($pipe, [Text.Encoding]::UTF8, $false, 4096, $true)
    $hello = $reader.ReadLine()
    if (-not $hello) { return }
    $parts = $hello.Trim() -split "\s+"
    if ($parts.Count -lt 2 -or $parts[0] -ne "HELLO") {
        Write-Log "bad hello: $hello"
        return
    }
    Write-Log "client HELLO ok session=$($parts[2])"
    while ($true) {
        $line = $reader.ReadLine()
        if ($null -eq $line) { break }
        $line = $line.Trim()
        if (-not $line) { continue }
        if ($line.ToUpperInvariant() -eq "BYE") {
            Write-Log "BYE"
            break
        }
        try {
            $obj = $line | ConvertFrom-Json
            $n = Invoke-Events $obj
            if ($n -gt 0) { Write-Log "applied $n event(s)" }
        } catch {
            Write-Log "bad json: $($line.Substring(0, [Math]::Min(80, $line.Length)))"
        }
    }
}

Write-Log "listening \\\\.\\pipe\\$PipeName (elevated inject helper — not a UAC bypass)"
while ($true) {
    $pipe = $null
    try {
        # In-only: clients write HELLO/events; we do not require duplex open.
        # (Write-only CreateFile clients hang against some InOut servers.)
        $pipe = New-Object System.IO.Pipes.NamedPipeServerStream(
            $PipeName,
            [System.IO.Pipes.PipeDirection]::In,
            4,
            [System.IO.Pipes.PipeTransmissionMode]::Byte,
            [System.IO.Pipes.PipeOptions]::None,
            4096,
            4096
        )
        $pipe.WaitForConnection()
        Write-Log "client connected"
        Handle-Client $pipe
    } catch {
        Write-Log "session error: $($_.Exception.Message)"
    } finally {
        if ($pipe) {
            try { $pipe.Dispose() } catch {}
        }
    }
    if ($Once) { break }
    Start-Sleep -Milliseconds 200
}
Write-Log "exit"
