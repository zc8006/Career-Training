# Meme Scout / 土狗热点雷达 — 项目交接

更新时间：2026-09-08

## 1. 项目目标

构建一个 Meme 币热点雷达，用于尽早发现叙事和资金异动，同时过滤明显高风险项目。目标是提高筛选质量，不承诺收益，也不直接自动交易。

当前重点链：Solana、BNB Chain、Base。

## 2. 当前站点

- 站点名称：土狗热点雷达 / MEME SIGNAL LAB
- 线上地址：https://meme-scout.zc8006.chatgpt.site
- 托管：ChatGPT Sites（底层为 Cloudflare Worker）
- 访问范围：仅站点所有者
- 当前线上版本：v7
- 当前源码提交：`77b814a Support fingerprint-only collector pairing`
- v7 已发布，D1 试运行数据库和候选结果跟踪接口已生效
- 尚未镜像到独立的私有 GitHub 仓库

## 3. 已完成

### 当前线上 v7

- 接入 DEX Screener 真实行情
- 支持 SOL、BNB、BASE 筛选
- 展示价格、成交量、流动性、买卖次数、FDV、交易对年龄
- 按 DEX 行情计算“市场异动分”
- Boost 推广提示、基础行情风险提示、观察池与合约地址复制
- 明确显示未接入的数据源，避免把演示数据当成真实结论

### 已上线的采集与试运行功能

- 固定 IPv4 GMGN 只读采集器：`collector/gmgn-collector.mjs`
- 默认每 5 分钟串行采集；最短间隔限制为 60 秒
- 收到 429 时读取 `Retry-After`、`X-RateLimit-Reset` 或 `reset_at`
- 429 后不自动重试，冷却状态写入本地文件，重启后继续生效
- systemd 服务、配置示例与 VPS 部署说明
- D1 数据表及 Drizzle 迁移：
  - `tokens`
  - `market_snapshots`
  - `gmgn_risk_snapshots`
  - `radar_scores`
  - `collector_runs`
- 带 Bearer Token 鉴权的 GMGN 快照入库接口：`POST /api/ingest/gmgn`
- 雷达接口读取最新 GMGN 快照；数据库或采集器未就绪时自动降级为 DEX 数据
- 前端显示 GMGN 快照状态、更新时间、Holder、前 10 持仓和 Bundler 比例
- 删除 Cloudflare 直接调用 GMGN 的测试入口
- 快照保留 14 天，采集运行状态保留 30 天
- 构建、lint、渲染测试和采集器语法检查通过

## 4. 数据接入状态

| 数据源 | 状态 | 用途 |
|---|---|---|
| DEX Screener | 已上线 | 候选发现与实时行情 |
| GMGN | v7 接口已上线，待 VPS 后台服务启动 | 热门榜、安全字段、Holder、狙击/机器人/Bundler 指标 |
| GoPlus | 未接入 | 合约权限、蜜罐等安全检查 |
| Moralis | 方案讨论过，未启用 | Holder 数量和变化交叉验证 |
| Birdeye | 未接入 | Solana 新币发现 |
| Google Trends | 未接入 | 叙事扩散确认 |
| X / 社媒 | 未接入 | 社媒提及与传播速度 |

## 5. GMGN 排查结论

Cloudflare 环境请求 `GET https://openapi.gmgn.ai/v1/market/rank` 返回：

- HTTP 429
- API code 429
- `RATE_LIMIT_BANNED`
- 反复请求会继续顺延约 5 分钟冷却时间

Windows 本地执行以下命令成功：

```powershell
npx.cmd --yes gmgn-cli market trending --chain sol --interval 1h --limit 1 --raw
```

结论：GMGN API Key 与账号正常，问题是 Cloudflare 共享出口 IP。新加坡 Vultr VPS 已实测成功返回榜单；固定 IP 方案可用。真实响应为 `data.data.rank`，采集器已兼容。

## 6. 新版架构

```text
固定IPv4 VPS
  └─ GMGN只读采集器
       ├─ 串行请求、超时、限流、持久化冷却
       └─ Bearer Token 推送快照
                    ↓
Cloudflare Site 入库接口
  └─ D1 历史快照
                    ↓
热点雷达 API / 前端
  └─ DEX 实时行情 + 最新 GMGN 风险快照
```

GMGN Key 和入库 Token 只存在 VPS 环境变量中；站点只保存入库 Token 的 SHA-256 指纹，不持有两个原始密钥。候选掉出 GMGN 热榜后仍由 DEX Screener 跟踪 48 小时。

## 7. GMGN 硬性风险闸门 v1

当前源码在出现以下任一情况时标记为硬性剔除：

- GMGN 标记蜜罐/无法卖出
- 增发权限或冻结权限明确未放弃
- 流动性低于 3 万美元
- 前 10 持仓超过 50%
- 狙击钱包达到 20 个
- Bundler 比例超过 20%
- 机器人地址比例超过 50%
- 关联 Rug 比例超过 50%
- 开发团队持仓超过 15%
- GMGN 标记疑似刷量
- 1 小时涨幅超过 300%

这些是第一版保守阈值。上线积累真实快照后，需要根据误杀率调整；未触发闸门也不等于安全。

## 8. 密钥安全

- 任何 API Key、入库 Token 都不得提交到 GitHub
- GMGN 曾有一枚 Key 误发到聊天中，必须视为泄露并删除
- 使用重新生成的 GMGN 只读 Key
- 不在截图、聊天、URL、前端代码或日志中暴露 Key
- 不启用 GMGN 交易权限，不配置钱包私钥
- VPS 使用 `GMGN_API_KEY` 与 `MEME_SCOUT_INGEST_TOKEN`
- Site 使用 Token 指纹 `GMGN_INGEST_TOKEN_SHA256`，原始 Token 不离开 VPS

Windows 临时测试后清理：

```powershell
Remove-Item Env:GMGN_API_KEY
Remove-Variable SecureKey,Ptr
```

## 9. 下一步（按顺序）

1. 在 VPS 生成独立的长随机入库 Token，并只提交 SHA-256 指纹给 Site。
2. 从本仓库的 `Projects/meme-scout/collector/` 安装采集器、配置文件和 systemd 服务。
3. 使用新的 GMGN 只读 Key 执行一次 `--once` 测试。
4. 单次成功后启用 systemd，持续采集并跟踪候选币。
5. 自动保存入选价格以及 1h、6h、24h 结果、最高涨幅和最大回撤。
6. 至少积累 30 个完整 24h 样本后再展示试运行胜率并校准规则。
7. 再接入 X 喊单质量、GoPlus 安全和 BTC/SOL/BNB 大趋势模型。

## 10. 重要边界

- 网站用于研究和候选筛选，不构成投资建议
- 不自动买币
- 不启用 GMGN 交易权限
- 没有完整安全数据前，不把“市场异动分”称为“埋伏分”
- 不再让 Cloudflare 直接请求 GMGN
