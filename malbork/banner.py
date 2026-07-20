"""ASCII marks for the Malbork operator console."""

from __future__ import annotations

from malbork import __version__

# FIGlet-style wordmark (standard, monospace-friendly).
_WORDMARK = r"""
 __  __       _ _                _
|  \/  | __ _| | |__   ___  _ __| | __
| |\/| |/ _` | | '_ \ / _ \| '__| |/ /
| |  | | (_| | | |_) | (_) | |  |   <
|_|  |_|\__,_|_|_.__/ \___/|_|  |_|\_\
""".strip(
    "\n"
)

# Concentric fortress — keep · walls · towers (Malbork / purple-castle desk).
_GLYPH = r"""
            /^\\
           /   \\
      /\\  |^^^|  /\\
     /  \\_|   |_/  \\
    | [] |  ·  | [] |
    |____|_____|____|
     \\   keep   /
      \\_______/
   Teutonic brick · C2 for Reach
   channel · agents · plane · castle
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
        f"  Malbork v{ver}  ·  type help",
    ]
    return "\n".join(lines)


def banner_short() -> str:
    """One-shot compact mark (e.g. after clear)."""
    return (
        "  ┌──────────── MALBORK ────────────┐\n"
        "  │  ⚔  keep  ·  C2 desk for Reach  │\n"
        "  └─────────────────────────────────┘"
    )
