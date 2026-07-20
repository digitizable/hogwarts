# Handset

<p align="center">
  <img src="icon.svg" alt="Handset" width="128" height="128"/>
</p>

<p align="center">
  <strong>C2 for Reach</strong> — agents, channel, reverse listener, egress, control plane, console, playbooks.
</p>

Handset is a **command-and-control desk** plugin for [Reach](https://github.com/digitizable/reach): path-aware channel status, implant roster against your control plane, reverse listener notes, egress probing (direct vs SOCKS path), interactive console, agent package shortcuts, and session playbooks.

## Install

In Reach → **Plugins** marketplace:

```text
digitizable/reach-plugin-handset
```

Requires Reach ≥ 0.5 (plugin host, `reach-plugin.json` schema 1).

### Local dev

```bash
# From this repo (or programs/handset checkout)
rsync -a --delete \
  --exclude .git --exclude __pycache__ \
  ./ ~/.local/share/reach/plugins/com__digitizable__handset/
```

Restart Reach (or re-open the Handset page) after changes.

## Features

| Panel | What |
|-------|------|
| **Channel** | Live path hero, SOCKS / hops / fingerprint / plane, quick actions |
| **Agents** | Fleet roster from `GET /api/v1/agents` (empty until plane is live) |
| **Listener** | Accept host/port, transport, cover face, agent id, ops notes |
| **Egress** | TCP matrix direct vs path SOCKS; custom targets |
| **Console** | Interactive ops shell (`help`, `status`, `pull`, `agents`, …) |
| **Plane** | Control-plane URL + token + health check |
| **Ops kit** | Reverse export folder, playbook JSON, plugin data dir |
| **Session log** | Local activity trail |

## Control plane

Handset does **not** host implants. Point **Plane** at your API:

| Endpoint | Role |
|----------|------|
| `GET /api/v1/health` | Connectivity check |
| `GET /api/v1/agents` | Fleet roster |
| `GET /api/v1/events` | Console `pull` |

Full contract: [handset/backend/CONTRACT.md](handset/backend/CONTRACT.md).

Config lives under:

```text
~/.local/share/reach/plugin-data/com__digitizable__handset/plane.json
```

## Layout

```
ui.py                 # Reach entry (create_page)
handset/
  page.py             # shell + wiring
  theme.py / net.py / store.py / widgets.py
  backend/            # control-plane client + contract
  panels/             # Channel · Agents · Listener · …
```

## Icons

| File | Use |
|------|-----|
| [`icon.svg`](icon.svg) | Marketplace / README (full color) |
| [`icon-symbolic.svg`](icon-symbolic.svg) | Reach left rail (themed monochrome) |

See [SOURCES.md](./SOURCES.md).

## License

GPL-3.0-or-later
