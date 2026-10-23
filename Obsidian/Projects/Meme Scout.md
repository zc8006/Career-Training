---
tags:
  - project
---

# Meme Scout

[[Projects/Projects_MOC|← 项目知识地图]]

## 项目目标

通过链上行情与风险快照发现候选币，使用含Gas、手续费和滑点的模拟交易验证选币、买入和卖出规则。目前为模拟，不涉及实盘交易。

## 复盘与经验

- [[Projects/Meme-Scout/2026-10-23-v49-code-review|2026-10-23 第49版审查与第50版修复]]：修正停采时逾期样本漏出覆盖率分母的问题；129项测试、类型及构建通过，已上线，无需VPS更新。

- [[Projects/Meme-Scout/2026-10-23-improvement-implementation-review|2026-10-23 第49版改善实施与验收]]：未买候选四时点复盘、配对诊断、收益指标与入场涨价过滤独立实验；126项检查通过，已发布并确认新入库，收益仍待验证。
- [[Projects/Meme-Scout/2026-10-23-improvement-implementation-plan|2026-10-23 四项改善清单]]：已实施，保留原基准和冻结协议，附验收边界。

- [[Projects/Meme-Scout/2026-10-22-strategy-reset-review|2026-10-22 策略重梳与24笔逐笔归因]]：20笔平仓4胜16负；14笔亏损的持有期采样最高涨幅不足10%，区分入场、采样跳价和费用，明确规则取舍。
- [[Projects/Meme-Scout/2026-10-19-wallet-flow-plan|2026-10-19 BSC钱包行为实验方案]]：钱包采集第48版修复记录；VPS安装版本待日志核验。补充覆盖原因统计及旧冲突过期修复，48h/95%规则保留。
- [[Projects/Meme-Scout/2026-10-19-wallet-flow-implementation-review|2026-10-19 实施总结]]：第48版116项测试、真实质量原因核对、明确未解决的批量归属问题，区分工程与收益证据。
- [[Projects/Meme-Scout/2026-10-16-signal-audit-plan|2026-10-16 选币优势验证与改善方案]]：第一阶段已实施，固定V7.5基准、前瞻同类对照、七日记录及后续信号研究。
- [[Projects/Meme-Scout/2026-10-16-implementation-review|2026-10-16 实施总结]]：第42版发布、79项测试、上线核对及固定时点数据。
- [[Projects/Meme-Scout/Self-Growth-Mode|自我成长模式]]：假设、冻结规则、新证据、复核门槛、结论修正及下一轮实验。
- [[Projects/Meme-Scout/2026-09-30-trading-lessons|2026-09-30 买卖经验与卖出后价格复盘]]：BSC覆盖、止损与反弹、分批止盈、盈利集中度、二次入场实验建议及数据缺口。

## 维护原则

正式知识记录统一保存在 Obsidian/Projects/ 下。仓库根目录 Projects/meme-scout/ 是历史来源，不作为新的知识记录写入位置。日期复盘保留当时的统计口径，待验证方案与已上线规则分别标注。
