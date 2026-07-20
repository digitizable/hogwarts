# Handset — Control plane contract

Handset is the **operator desk** inside Reach. Live fleet data comes from a C2
**control-plane API** you host. Until that API is configured, Agents stays empty
and local tools (channel, egress, listener notes, playbooks) still work.

Config is stored under Reach plugin data:
`~/.local/share/reach/plugin-data/com__digitizable__handset/plane.json`

---

## Base

| Item | Requirement |
|------|-------------|
| Transport | HTTPS (HTTP only on localhost/dev) |
| Format | JSON, UTF-8 |
| Auth | `Authorization: Bearer <token>` |
| Time | ISO-8601 UTC |
| Errors | `{ "error": { "code": "…", "message": "…" } }` + HTTP status |

---

## Health

```
GET /api/v1/health
→ 200 { "status": "ok", "version": "…", "time": "…" }
```

---

## Agents

```
GET /api/v1/agents?status=online|idle|offline&q=<search>&limit=200
→ 200 {
  "agents": [
    {
      "id": "agt_…",
      "hostname": "wkstn-04",
      "username": "jdoe",
      "os": "Windows 11",
      "arch": "x64",
      "status": "online",
      "last_seen": "…Z",
      "external_ip": "203.0.113.1",
      "internal_ip": "10.0.0.12",
      "group": "red-team",
      "tags": ["vip"],
      "sleep": 5,
      "jitter": 0.2
    }
  ],
  "next_cursor": null
}
```

```
GET /api/v1/agents/{id}
→ 200 { "agent": { … } }
```

```
POST /api/v1/agents/{id}/tasks
Body: { "type": "shell|file|…", "payload": { … } }
→ 202 { "task_id": "tsk_…", "status": "queued" }
```

---

## Events

```
GET /api/v1/events?since=<iso>&limit=100
→ 200 {
  "events": [
    {
      "ts": "…Z",
      "level": "info|ok|warn|error",
      "channel": "agent|listener|task|system",
      "message": "…",
      "agent_id": "…?"
    }
  ]
}
```

Optional later: WebSocket `/api/v1/events/ws`.
