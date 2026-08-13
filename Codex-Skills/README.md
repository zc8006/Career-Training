# Codex Skills Conversion

This directory converts the supplied `skills.zip` into a Codex-compatible bundle.

## Included skills

`brainstorming`, `canvas-design`, `docx`, `excalidraw-diagram-generator`, `executing-plans`, `frontend-design`, `frontend-slides`, `mcp-builder`, `pdf`, `pptx`, `skill-creator`, `writing-skills`, and `xlsx`.

## 技能说明

| Skill | 功能说明 | 什么时候使用 |
| --- | --- | --- |
| `brainstorming` | 需求头脑风暴（动手前先理清思路） | 写功能、做设计、开发前，需要先梳理需求、方案、边界和取舍时，例如“先一起头脑风暴一下”。 |
| `canvas-design` | 海报与视觉艺术设计 | 生成精美海报、视觉稿、艺术图等设计作品，并输出 PNG / PDF 时。 |
| `docx` | Word 文档生成与处理 | 创建、读取、编辑 `.docx`，制作带目录、页码、标题层级等正式文档或报告时。 |
| `excalidraw-diagram-generator` | Excalidraw 手绘风图表生成 | 绘制流程图、架构图、思维导图、关系图等，并输出 `.excalidraw` 文件时。 |
| `executing-plans` | 按既定计划分步执行 | 已经有明确实施计划，需要按步骤执行、设置检查点并逐项验证时。 |
| `frontend-design` | 高质量前端界面生成 | 开发网页、组件、落地页、后台、仪表盘等，希望 UI 更完整、更美观、更有设计感时。 |
| `frontend-slides` | HTML 网页版演示文稿 | 制作可在浏览器中播放的 HTML 幻灯片，或将演示内容做成网页形式时。 |
| `mcp-builder` | MCP 服务端开发指南 | 开发连接外部 API、数据库或服务的 MCP Server，尤其是 Python / Node.js 实现时。 |
| `pdf` | PDF 文件多功能处理 | 读取、生成、合并、拆分、加水印、填表、提取内容或处理 OCR 等 PDF 任务时。 |
| `pptx` | PPT 幻灯片解析与生成 | 创建、读取、编辑 `.pptx` 演示文稿，或对现有 PPT 做结构、内容和版式调整时。 |
| `skill-creator` | 自定义 Skill 创建指南 | 想创建一个新的本地 Skill、定义触发条件、组织 `SKILL.md`、脚本和资源文件时。 |
| `writing-skills` | Skill 编写 / 校验规范 | 创建、修改、审查或验证 Skill 是否符合 Codex 使用规范、是否存在失效依赖时。 |
| `xlsx` | Excel 表格数据处理 | 创建、读取、编辑 `.xlsx` / `.csv`，处理公式、数据清洗、统计分析、透视或图表时。 |

## Main compatibility changes

- `~/.claude/skills` → `~/.agents/skills`
- `CLAUDE.md` → `AGENTS.md`
- Claude-specific wording/default authors → Codex
- removed hard dependencies on `TodoWrite` and unavailable `superpowers:*` skills
- rewrote `brainstorming`, `executing-plans`, and `writing-skills` as self-contained Codex workflows
- rewrote the MCP evaluation harness to use the OpenAI Responses API instead of the Anthropic SDK
- removed bundled font binaries from `canvas-design`; use system/user-provided fonts instead

## Build

```bash
python Codex-Skills/build_codex_skills.py skills.zip -o codex-skills.zip
```

The builder validates all 13 `SKILL.md` files, compiles Python sources, checks JavaScript syntax when Node.js is available, and rejects stale active Claude/Superpowers dependencies.

## Install

User-level installation:

```bash
python Codex-Skills/install.py codex-skills.zip
```

Project-level installation:

```bash
python Codex-Skills/install.py codex-skills.zip --project
```

The default destinations are `~/.agents/skills/` and `./.agents/skills/` respectively. Use `--force` to replace existing skills.

## Notes

The optional `mcp-builder` evaluation harness uses the OpenAI Python SDK and `OPENAI_API_KEY`. Its default model is `gpt-5`; use `--model` to select another model available to your API account.
