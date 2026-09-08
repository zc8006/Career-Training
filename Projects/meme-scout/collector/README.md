# Fixed-IPv4 GMGN collector

This process runs on a small VPS with a stable public IPv4 address. It calls the
GMGN read-only ranking endpoint and sends snapshots to Meme Scout. The Site never
receives the GMGN key and never calls GMGN directly.

## Safety and rate-limit behavior

- The default schedule is one request every five minutes, sequentially per chain.
- After each GMGN cycle, candidates that passed the first risk gate are refreshed
  through DEX Screener even if they have already disappeared from the GMGN rank.
- Candidate outcomes are sampled for 48 hours; the Site records 1h, 6h, and 24h
  prices plus the 24h peak and drawdown.
- The interval cannot be configured below 60 seconds.
- A 429 response is never retried automatically.
- `Retry-After`, `X-RateLimit-Reset`, and GMGN `reset_at` are honored.
- Cooldown state is written atomically and survives process restarts.
- Only a read-only GMGN key is required. Do not configure a wallet private key or
  trading permission.

## VPS setup

1. Install Node.js 22 or newer and create an unprivileged `meme-scout` user.
2. Copy this repository to `/opt/meme-scout`.
3. Create `/etc/meme-scout/gmgn.env` from `config.example`, mode `0600`.
4. Use a new GMGN read-only key and a separate long random ingest token.
5. Copy `meme-scout-gmgn.service` to `/etc/systemd/system/`, then enable it.

Run one safe connectivity check before enabling the timer-like loop:

```bash
node collector/gmgn-collector.mjs --once
```

Start the service only after that single run succeeds:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now meme-scout-gmgn
```

Keep both secrets out of Git, shell history, screenshots, URLs, and logs. Keep
`MEME_SCOUT_INGEST_TOKEN` only on the VPS and configure its SHA-256 fingerprint
as the Site runtime value `GMGN_INGEST_TOKEN_SHA256`. The token itself never
needs to leave the server. The older `GMGN_INGEST_TOKEN` secret remains
supported as a fallback.
