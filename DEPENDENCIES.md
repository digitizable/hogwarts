# Hogwarts dependencies

## keepstream (Gitea only)

Desk client + agent server + H.264 decode.

```text
git@gitea.anguish.sh:anguish/keepstream.git
```

**Not** published on GitHub (removed).

Vendored as git submodule: `third_party/keepstream`

```bash
git clone --recurse-submodules git@github.com:digitizable/hogwarts.git
# keepstream submodule URL is Gitea — ensure SSH config for gitea.anguish.sh
git submodule update --init --recursive
```

```python
from keepstream import KeepstreamClient
from keepstream.server import session_start, session_stop
from keepstream.h264dec import ensure_gst_init
```
