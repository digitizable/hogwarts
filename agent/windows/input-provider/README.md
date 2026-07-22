# Hogwarts input provider (Windows)

**High integrity** helper for Keepstream / Control inject when the agent is Medium IL.

Not a UAC bypass. Install once elevated; daily start is silent via Task Scheduler.

## Why

UIPI blocks Medium agents from injecting into Task Manager and other High UI. Either:

1. Elevate the **whole agent** (`..\install-elevated-task.ps1`), or  
2. Keep the agent Medium and run **this** High helper; agent forwards INPUT over a named pipe.

## One-time install (one UAC Yes)

Elevated PowerShell:

```powershell
cd <repo>\agent\windows\input-provider
.\install-input-provider-task.ps1 -AtLogon
.\start-input-provider-silent.ps1
```

## agent.json

```json
"input_provider": {
  "enabled": true,
  "kind": "pipe",
  "pipe": "\\\\.\\pipe\\hogwarts-input"
}
```

Or Remote Viewer → Session → **Use provider** with a custom exec path (prefer pipe).

## Protocol

`hogwarts-input/1` (see CONTRACT / research notes):

```
Agent → Helper:  HELLO hogwarts-input/1 <session_id> <psk>\n
Helper → Agent:  HELLO_OK\n
Agent → Helper:  {"events":[{"type":"click","fx":0.5,"fy":0.5},…]}\n
Agent → Helper:  BYE\n
```

## Verify

1. Helper running (task or `powershell -File HogwartsInputProvider.ps1`).  
2. Agent online Medium; `session_start` result includes `"input_provider":{"active":true,"kind":"pipe",…}`.  
3. Control / Session click on Task Manager should work.

## Anti-patterns

| Action | Result |
|--------|--------|
| Point `exec` at a self-elevating script | UAC every Session |
| Helper not running when Session starts | provider connect fails → local inject |
| Agent already elevated | provider optional; local SendInput can hit High UI |
