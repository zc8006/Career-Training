# Meme Scout / 土狗热点雷达 — 项目交接

更新时间：2026-09-08

## 1. 项目目标

构建一个 Meme 币热点雷达，用于尽早发现叙事和资金异动，同时过滤明显高风险项目。目标是提高筛选质量，不承诺收益，也不直接自动交易。

当前重点链：

- Solana
- BNB Chain
- Base

## 2. 当前站点

- 站点名称：土狗热点雷达 / MEME SIGNAL LAB
- 线上地址：https://meme-scout.zc8006.chatgpt.site
- 托管：ChatGPT Sites（底层为 Cloudflare Worker）
- 访问范围：仅站点所有者
- 当前线上版本：v5
- 当前源码状态保存在 Sites 的项目源码仓库中，尚未镜像到独立 GitHub 仓库

## 3. 已完成功能

- 接入 DEX Screener 真实行情
- 支持 SOL、BNB、BASE 筛选
- 展示价格、成交量、流动性、买卖次数、FDV、交易对年龄
- 按 DEX 行情计算“市场异动分”
- Boost 推广提示
- 基础行情风险提示
- 观察池与合约地址复制
- 明确显示未接入的数据源，避免把演示数据当成真实结论
- 新增仅所有者可访问的 GMGN 单次连接测试
- GMGN 测试 Key 只用于当次后端请求，不保存、不回显
- 构建、lint 和渲染测试已通过

## 4. 当前数据接入状态

| 数据源 | 状态 | 用途 |
|---|---|---|
| DEX Screener | 已接入 | 候选发现与实时行情 |
| GMGN | 已验证API可用，但Cloudflare出口被封 | 热门榜、安全字段、Holder、狙击/机器人/Bundler指标 |
| GoPlus | 未接入 | 合约权限、蜜罐等安全检查 |
| Moralis | 接口方案已讨论，未在当前站点启用 | Holder数量和变化 |
| Birdeye | 未接入 | Solana新币发现 |
| Google Trends | 未接入 | 叙事扩散确认 |
| X / 社媒 | 未接入 | 社媒提及与传播速度 |

## 5. GMGN排查结论

### Cloudflare测试

两个Cloudflare环境均调用：

- 接口：GET https://openapi.gmgn.ai/v1/market/rank
- Header：X-APIKEY
- 参数：chain=sol、interval=1h、limit=1或5

均返回：

- HTTP 429
- API code 429
- error：RATE_LIMIT_BANNED
- message：IP is temporarily banned due to repeated rate limit violations

反复请求会把约5分钟的冷却时间继续顺延。

### Windows本地测试

PowerShell正确命令：

```powershell
npx.cmd --yes gmgn-cli market trending --chain sol --interval 1h --limit 1 --raw
```

本地结果：

- code = 0
- message = success
- 成功返回 Solana 热门币数据

结论：

- GMGN API Key与账号正常
- 问题集中在Cloudflare共享出口IP
- 换Cloudflare域名或换另一个Cloudflare Worker不能解决
- 不应继续从Cloudflare直接请求GMGN

## 6. 密钥安全

- 任何API Key都不得提交到GitHub
- GMGN曾有一枚Key误发到聊天中，必须视为泄露并删除
- 当前测试应使用重新生成的新Key
- 不要在截图、聊天、URL、前端代码或日志中暴露Key
- 网站只做查询，不启用GMGN交易权限
- 不配置GMGN私钥
- Windows临时环境变量测试后执行：

```powershell
Remove-Item Env:GMGN_API_KEY
Remove-Variable SecureKey,Ptr
```

## 7. GMGN返回数据的价值

本地测试返回了DEX Screener没有完整提供的字段，例如：

- holder_count
- top_10_holder_rate
- sniper_count
- smart_degen_count
- bundler_rate
- bot_degen_count / bot_degen_rate
- rug_ratio
- renounced_mint
- renounced_freeze_account
- is_honeypot
- dev_team_hold_rate
- wash trading标记
- 社媒重复与改名信息

测试样本一小时涨幅超过1196%，流动性约1.33万美元，同时包含300个机器人地址、41个狙击钱包和约18.13%的Bundler比例，说明热门榜必须结合风险闸门，不能直接作为买入榜。

## 8. 推荐生产架构

```text
固定IPv4采集服务
  ├─ 定时请求GMGN
  ├─ 严格限流、缓存、退避
  └─ 写入数据库
          ↓
Cloudflare上的热点雷达
  └─ 只读取数据库快照，不直接请求GMGN
```

建议：

1. 使用一台带固定公网IPv4的小型VPS运行采集器。
2. GMGN只读Key保存在VPS环境变量中。
3. 每1～5分钟采集一次热门候选；高权重接口降低频率。
4. 收到429后读取reset_at或X-RateLimit-Reset，停止请求到指定时间。
5. 禁止自动连续重试。
6. 数据库保存历史快照，用于计算成交、Holder、流动性和风险变化速度。
7. Cloudflare前端只读取缓存后的结果。

GitHub Actions同样使用共享出口IP，不适合作为已知IP限流问题的长期GMGN采集器。

## 9. 下一步开发顺序

1. 建立独立的 `meme-scout` 私有GitHub仓库并镜像完整站点源码。
2. 设计并实现固定IPv4 GMGN采集器。
3. 建立数据库表：tokens、market_snapshots、gmgn_risk_snapshots、radar_scores。
4. 将GMGN字段作为硬性风险闸门，而不是简单加分。
5. 前端增加GMGN状态、数据时间、来源和失败降级。
6. 接入Birdeye补全Solana新币发现。
7. 接入Moralis/GoPlus交叉验证Holder和合约安全。
8. 最后接Google Trends与社媒，只作为叙事确认信号。

## 10. 评分原则

不要按涨幅直接排序。建议分两层：

### 硬性剔除

- 蜜罐/无法卖出
- 可随意增发或冻结
- 流动性严重不足
- Bundler、狙击或大户集中度过高
- 机器人交易占比异常
- 价格已极端拉升

### 候选评分

- 成交量加速度
- 买卖钱包与交易数加速度
- 流动性增长
- Holder增长
- 聪明钱进入
- 搜索/社媒热度领先价格
- 风险扣分

## 11. 下个窗口继续方式

在新聊天中发送：

> 请读取GitHub里的 `Projects/meme-scout/HANDOFF.md`，继续“土狗热点雷达”项目。先不要让Cloudflare直接调用GMGN；从固定IPv4采集器、数据库和严格限流开始设计与实现。

## 12. 重要边界

- 当前网站用于研究和候选筛选，不构成投资建议
- 不自动买币
- 不启用GMGN交易权限
- 没有完整安全数据前，不把“市场异动分”称为“埋伏分”
