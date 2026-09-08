#!/usr/bin/env node
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { randomUUID } from "node:crypto";

const apiKey = process.env.GMGN_API_KEY?.trim();
const ingestUrl = process.env.MEME_SCOUT_INGEST_URL?.trim();
const trackingUrl = process.env.MEME_SCOUT_TRACKING_URL?.trim() || ingestUrl?.replace(/\/gmgn\/?$/, "/tracking");
const ingestToken = process.env.MEME_SCOUT_INGEST_TOKEN?.trim();
const apiUrl = process.env.GMGN_API_URL?.trim() || "https://openapi.gmgn.ai/v1/market/rank";
const statePath = process.env.MEME_SCOUT_STATE_PATH?.trim() || "/var/lib/meme-scout/collector-state.json";
const chains = (process.env.GMGN_CHAINS || "sol").split(",").map((item) => item.trim()).filter(Boolean);
const intervalSeconds = Math.max(60, Number.parseInt(process.env.GMGN_INTERVAL_SECONDS || "300", 10) || 300);
const requestLimit = Math.min(100, Math.max(1, Number.parseInt(process.env.GMGN_RESULT_LIMIT || "50", 10) || 50));
const once = process.argv.includes("--once");

if (!apiKey || !ingestUrl || !ingestToken) {
  console.error("GMGN_API_KEY, MEME_SCOUT_INGEST_URL and MEME_SCOUT_INGEST_TOKEN are required.");
  process.exit(1);
}

async function loadState() {
  try { return JSON.parse(await readFile(statePath, "utf8")); }
  catch { return { nextAllowedAt: {} }; }
}

async function saveState(state) {
  await mkdir(dirname(statePath), { recursive: true });
  const temporary = `${statePath}.${process.pid}.tmp`;
  await writeFile(temporary, `${JSON.stringify(state, null, 2)}\n`, { mode: 0o600 });
  await rename(temporary, statePath);
}

function headerEpoch(response, name) {
  const value = response.headers.get(name);
  if (!value) return null;
  const numeric = Number(value);
  if (Number.isFinite(numeric)) return numeric > 10_000_000_000 ? numeric : numeric * 1000;
  const parsed = Date.parse(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function cooldownUntil(response, body) {
  const retryAfter = response.headers.get("retry-after");
  if (retryAfter && Number.isFinite(Number(retryAfter))) return Date.now() + Number(retryAfter) * 1000;
  const candidates = [
    headerEpoch(response, "x-ratelimit-reset"),
    typeof body?.reset_at === "number" ? body.reset_at * (body.reset_at > 10_000_000_000 ? 1 : 1000) : null,
    typeof body?.data?.reset_at === "number" ? body.data.reset_at * (body.data.reset_at > 10_000_000_000 ? 1 : 1000) : null,
  ].filter((value) => typeof value === "number" && value > Date.now());
  return candidates.length ? Math.max(...candidates) : Date.now() + 5 * 60_000;
}

function recordsFrom(body) {
  if (Array.isArray(body?.data?.data?.rank)) return body.data.data.rank;
  if (Array.isArray(body?.data?.rank)) return body.data.rank;
  if (Array.isArray(body?.data)) return body.data;
  if (Array.isArray(body?.rank)) return body.rank;
  return [];
}

async function report(payload, destination = ingestUrl) {
  const response = await fetch(destination, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${ingestToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
    signal: AbortSignal.timeout(15_000),
  });
  if (!response.ok) throw new Error(`Ingest endpoint returned HTTP ${response.status}`);
  return response.json().catch(() => null);
}

async function trackingTargets() {
  const response = await fetch(trackingUrl, {
    headers: { Authorization: `Bearer ${ingestToken}`, Accept: "application/json" },
    signal: AbortSignal.timeout(15_000),
  });
  if (!response.ok) throw new Error(`Tracking target endpoint returned HTTP ${response.status}`);
  const body = await response.json();
  return Array.isArray(body?.targets) ? body.targets : [];
}

function dexNumber(value) {
  const parsed = Number(value ?? 0);
  return Number.isFinite(parsed) ? parsed : 0;
}

async function trackCandidates() {
  if (!trackingUrl) return;
  const targets = await trackingTargets();
  if (!targets.length) {
    console.log(JSON.stringify({ event: "tracking_idle", targets: 0 }));
    return;
  }

  const grouped = new Map();
  for (const target of targets) {
    if (!target?.chain || !target?.address) continue;
    const list = grouped.get(target.chain) ?? [];
    list.push(target.address);
    grouped.set(target.chain, list);
  }

  const records = [];
  for (const [chain, addresses] of grouped) {
    for (let index = 0; index < addresses.length; index += 30) {
      const batch = addresses.slice(index, index + 30);
      const url = `https://api.dexscreener.com/tokens/v1/${encodeURIComponent(chain)}/${batch.map(encodeURIComponent).join(",")}`;
      const response = await fetch(url, { headers: { Accept: "application/json" }, signal: AbortSignal.timeout(12_000) });
      if (!response.ok) throw new Error(`DEX tracking returned HTTP ${response.status}`);
      const pairs = await response.json();
      if (!Array.isArray(pairs)) continue;
      for (const address of batch) {
        const normalized = chain === "bsc" || chain === "base" ? address.toLowerCase() : address;
        const candidates = pairs.filter((pair) => {
          const value = String(pair?.baseToken?.address ?? "");
          return (chain === "bsc" || chain === "base" ? value.toLowerCase() : value) === normalized;
        });
        candidates.sort((left, right) => dexNumber(right?.liquidity?.usd) - dexNumber(left?.liquidity?.usd));
        const pair = candidates[0];
        if (!pair) continue;
        records.push({
          chain,
          address,
          priceUsd: dexNumber(pair.priceUsd),
          liquidityUsd: dexNumber(pair.liquidity?.usd),
          volume1hUsd: dexNumber(pair.volume?.h1),
          priceChange1h: dexNumber(pair.priceChange?.h1),
          buys1h: dexNumber(pair.txns?.h1?.buys),
          sells1h: dexNumber(pair.txns?.h1?.sells),
        });
      }
    }
  }

  const collectedAt = new Date().toISOString();
  const runId = `${Date.now()}-tracking-${randomUUID()}`;
  await report({ runId, collectedAt, records, targetTokenIds: targets.map((target) => target.tokenId) }, trackingUrl);
  console.log(JSON.stringify({ event: "tracking_collected", targets: targets.length, records: records.length }));
}

async function collect(chain, state) {
  const blockedUntil = Number(state.nextAllowedAt?.[chain] || 0);
  if (blockedUntil > Date.now()) {
    console.log(JSON.stringify({ event: "cooldown_skip", chain, nextAllowedAt: new Date(blockedUntil).toISOString() }));
    return;
  }

  const startedAt = new Date().toISOString();
  const runId = `${Date.now()}-${chain}-${randomUUID()}`;
  const url = new URL(apiUrl);
  url.search = new URLSearchParams({
    chain,
    interval: "1h",
    limit: String(requestLimit),
    timestamp: String(Math.floor(Date.now() / 1000)),
    client_id: randomUUID(),
  }).toString();

  let response;
  let body;
  try {
    response = await fetch(url, {
      headers: { "X-APIKEY": apiKey, Accept: "application/json" },
      redirect: "manual",
      signal: AbortSignal.timeout(12_000),
    });
    body = await response.json().catch(() => null);
  } catch (error) {
    const collectedAt = new Date().toISOString();
    await report({ runId, chain, startedAt, collectedAt, status: "network_error", message: error instanceof Error ? error.message : "GMGN request failed", records: [] });
    console.error(JSON.stringify({ event: "gmgn_error", chain, message: error instanceof Error ? error.message : "request failed" }));
    return;
  }

  if (response.status === 429 || body?.code === 429) {
    const nextAllowedAt = cooldownUntil(response, body);
    state.nextAllowedAt ??= {};
    state.nextAllowedAt[chain] = nextAllowedAt;
    await saveState(state);
    await report({
      runId, chain, startedAt, collectedAt: new Date().toISOString(), status: "rate_limited",
      httpStatus: response.status, apiCode: body?.code, cooldownUntil: new Date(nextAllowedAt).toISOString(),
      message: String(body?.message || body?.error || "GMGN rate limited").slice(0, 500), records: [],
    });
    console.warn(JSON.stringify({ event: "rate_limited", chain, nextAllowedAt: new Date(nextAllowedAt).toISOString() }));
    return;
  }

  const records = recordsFrom(body);
  const ok = response.ok && (body?.code === undefined || body.code === 0) && records.length > 0;
  const collectedAt = new Date().toISOString();
  await report({
    runId, chain, startedAt, collectedAt, status: ok ? "success" : "api_error",
    httpStatus: response.status, apiCode: body?.code,
    message: ok ? null : String(body?.message || body?.error || "GMGN returned no records").slice(0, 500),
    records: ok ? records : [],
  });
  console.log(JSON.stringify({ event: ok ? "collected" : "api_error", chain, records: records.length, httpStatus: response.status, apiCode: body?.code ?? null }));
}

async function cycle() {
  const state = await loadState();
  for (const chain of chains) await collect(chain, state);
  try { await trackCandidates(); }
  catch (error) { console.error(JSON.stringify({ event: "tracking_error", message: error instanceof Error ? error.message : "tracking failed" })); }
}

await cycle();
if (!once) {
  const scheduleNext = () => {
    setTimeout(async () => {
      try { await cycle(); }
      catch (error) { console.error(JSON.stringify({ event: "cycle_error", message: error.message })); }
      scheduleNext();
    }, intervalSeconds * 1000);
  };
  scheduleNext();
}
