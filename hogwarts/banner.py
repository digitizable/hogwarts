"""ASCII marks for the Hogwarts operator console.

Castle silhouette adapted from public castle ASCII (community / unknown
artists; see SOURCES.md). Wordmark is original monospace lettering.
"""

from __future__ import annotations

from hogwarts import __version__

# Compact wordmark (fits ~72 cols with the keep below).
_WORDMARK = r"""
  _   _                                  _
 | | | | ___   __ ___      ____ _ _ __| |_ ___
 | |_| |/ _ \ / _` \ \ /\ / / _` | '__| __/ __|
 |  _  | (_) | (_| |\ V  V / (_| | |  | |_\__ \
 |_| |_|\___/ \__, | \_/\_/ \__,_|_|   \__|___/
              |___/
""".strip(
    "\n"
)

# Multi-tower keep — adapted from classic pure-ASCII castle art
# (asciiart.eu castles gallery; artists unknown / community).
# Trimmed for GTK console width and labeled as the Hogwarts desk splash.
_CASTLE = r"""
                         |>>>                      |>>>
                 |>>>    |                         |
                 |       *            |>>>         *
                / \                  / \          / \
               /___\      _/\_      /___\        /___\
               [   ]     |/  \|     [   ]        [   ]
               [ I ]   _/      \_   [ I ]        [ I ]
               [   ]__/  .--.   \__[   ]________[   ]
               [   ]    /||||\      [   ]  KEEP  [   ]
               [___]===/||||||\=====[___]========[___]
                  \\__/||||||||\____//
                   `===\||||||||/==='
                      /||||||||\
   C2 desk for Reach · channel · agents · plane · defend the keep
""".strip(
    "\n"
)

# Smaller mark when full splash is too tall (clear / compact).
_CASTLE_SMALL = r"""
      /\                /\
     /  \___/\___/\___/  \
    | [] |  KEEP  | [] |
    |____|__||||__|____|
       C2 · Reach operator desk
""".strip(
    "\n"
)


def banner(*, version: str | None = None) -> str:
    """Full splash for console boot / `banner` command."""
    ver = version if version is not None else __version__
    return "\n".join(
        [
            _WORDMARK,
            "",
            _CASTLE,
            "",
            f"  Hogwarts v{ver}  ·  type help",
        ]
    )


def banner_short() -> str:
    """One-shot compact mark (e.g. after clear)."""
    return "\n".join(
        [
            "  ┌─────────── HOGWARTS ───────────┐",
            _CASTLE_SMALL,
            "  └────────────────────────────────┘",
        ]
    )
