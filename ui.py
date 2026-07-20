"""Malbork plugin entry — Reach loads create_page(ctx)."""

from __future__ import annotations

import sys
from pathlib import Path


def create_page(ctx):
    """Install plugin root on sys.path so `malbork` package imports resolve."""
    root = Path(ctx.plugin_dir).resolve()
    root_s = str(root)
    if root_s not in sys.path:
        sys.path.insert(0, root_s)
    from malbork.page import MalborkPage

    return MalborkPage(ctx)
