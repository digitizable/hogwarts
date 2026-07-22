# Elevated agent without UAC Yes/No every time

## Why you still saw Yes/No

`Start-Process -Verb RunAs` / “Run as administrator” **always** shows the UAC consent dialog. That is by design on Windows. It is not a Keepstream bug.

Silent elevated start uses a **scheduled task** registered once with **RunLevel Highest**. Later launches go through Task Scheduler (`schtasks` / `Start-ScheduledTask`) and **do not** prompt.

## One-time install (one UAC prompt)

Open **elevated** PowerShell (this is the only Yes you should need):

```powershell
cd <repo>\agent\windows
# .NET agent:
.\install-elevated-task.ps1 -Exe "C:\path\to\Hogwarts.Agent.exe" -AtLogon
# or python lab agent:
.\install-elevated-task.ps1 -AgentDir "C:\path\to\agent" -AtLogon
```

## Daily start (no prompt)

```powershell
.\start-agent-silent.ps1
# equivalent:
schtasks /Run /TN "HogwartsAgentElevated"
```

With `-AtLogon`, the agent comes up elevated after login with no click.

## input_provider without prompts

Do **not** point `input_provider.command` at something that self-elevates (that re-triggers UAC).

### Shipped lab helper (recommended)

```powershell
cd <repo>\agent\windows\input-provider
# elevated once:
.\install-input-provider-task.ps1 -AtLogon
.\start-input-provider-silent.ps1
```

See `input-provider/README.md`. Protocol: `hogwarts-input/1` on `\\.\pipe\hogwarts-input`.

### agent.json

```json
"input_provider": {
  "enabled": true,
  "kind": "pipe",
  "pipe": "\\\\.\\pipe\\hogwarts-input"
}
```

Medium agent connects; High helper already running — **no** consent UI on Session start.

## Anti-patterns

| Action | Result |
|--------|--------|
| Right-click Run as administrator every time | UAC every time |
| `Start-Process -Verb RunAs` from scripts | UAC every time |
| `input_provider` exec that calls RunAs | UAC every Session |
| Highest scheduled task + silent start | No daily UAC |
