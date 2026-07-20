"""ASCII marks for the Handset operator console."""

from __future__ import annotations

from handset import __version__

# Compact FIGlet-ish wordmark + handset silhouette (monospace, ≤72 cols).
_WORDMARK = r"""
 _   _                 _           _
| | | | __ _ _ __   __| |___  ___ | |_
| |_| |/ _` | '_ \ / _` / __|/ _ \| __|
|  _  | (_| | | | | (_| \__ \  __/| |_
|_| |_|\__,_|_| |_|\__,_|___/\___| \__|
""".strip(
    "\n"
)

# Small radio / handset glyph (optional flair under the name).
_GLYPH = r"""
      .--.
     /    \      C2 desk for Reach
    |  ()  |     channel · agents · plane
     \    /      path-aware ops console
   ___'--'___
  /__________\
""".strip(
    "\n"
)


def banner(*, version: str | None = None) -> str:
    """Full splash for console boot / `banner` command."""
    ver = version if version is not None else __version__
    lines = [
        _WORDMARK,
        "",
        _GLYPH,
        "",
        f"  Handset v{ver}  ·  type help",
    ]
    return "\n".join(lines)


def banner_short() -> str:
    """One-shot compact mark (e.g. after clear)."""
    return (
        "  ┌──────────── HANDSET ────────────┐\n"
        "  │  (•)  C2 · Reach operator desk  │\n"
        "  └─────────────────────────────────┘"
    )
