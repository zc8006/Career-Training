#!/usr/bin/env python3
"""Convert the supplied skills.zip into a Codex-compatible skill bundle."""
from __future__ import annotations

import argparse
import py_compile
import re
import shutil
import stat
import subprocess
import tempfile
import zipfile
from pathlib import Path

TEXT_SUFFIXES = {".md", ".py", ".js", ".cjs", ".sh", ".txt", ".html", ".dot", ".xml", ".xsd", ".excalidraw"}
REPLACEMENTS = [
    ("~/.claude/skills", "~/.agents/skills"),
    ("Claude Code", "Codex"),
    ("CLAUDE.md", "AGENTS.md"),
    ("Claude", "Codex"),
    ("claude", "codex"),
    (".superpowers/brainstorm", ".codex/brainstorm"),
    ("docs/superpowers/specs", "docs/codex/specs"),
]
OVERRIDE_PATHS = [
    "brainstorming/SKILL.md",
    "executing-plans/SKILL.md",
    "writing-skills/SKILL.md",
    "mcp-builder/scripts/evaluation.py",
]


def _safe_target(base: Path, member_name: str) -> Path:
    member = Path(member_name)
    if member.is_absolute() or ".." in member.parts:
        raise SystemExit(f"Unsafe archive path: {member_name}")
    base = base.resolve()
    target = (base / member).resolve()
    if target != base and base not in target.parents:
        raise SystemExit(f"Unsafe archive path: {member_name}")
    return target


def safe_extract_zip(zf: zipfile.ZipFile, destination: Path) -> None:
    for info in zf.infolist():
        _safe_target(destination, info.filename)
        mode = (info.external_attr >> 16) & 0o170000
        if mode == stat.S_IFLNK:
            raise SystemExit(f"Archive contains unsupported symlink: {info.filename}")
    zf.extractall(destination)


def locate_skills(root: Path) -> Path:
    if (root / "skills").is_dir():
        return root / "skills"
    matches = [p for p in root.rglob("skills") if p.is_dir()]
    if len(matches) != 1:
        raise SystemExit("Could not uniquely locate the top-level skills/ directory")
    return matches[0]


def rewrite_text(skills: Path) -> None:
    for path in skills.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for old, new in REPLACEMENTS:
            text = text.replace(old, new)
        path.write_text(text, encoding="utf-8")

    old = skills / "writing-skills/examples/CLAUDE_MD_TESTING.md"
    if old.exists():
        old.rename(skills / "writing-skills/examples/AGENTS_MD_TESTING.md")


def copy_overrides(skills: Path, script_dir: Path) -> None:
    for rel in OVERRIDE_PATHS:
        src = script_dir / "overrides" / rel
        dst = skills / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)

    testing = skills / "writing-skills/testing-skills-with-subagents.md"
    if testing.exists():
        text = testing.read_text(encoding="utf-8")
        text = text.replace(
            "**REQUIRED BACKGROUND:** You MUST understand superpowers:test-driven-development before using this skill. That skill defines the fundamental RED-GREEN-REFACTOR cycle. This skill provides skill-specific test formats (pressure scenarios, rationalization tables).",
            "**Background:** This guide uses a RED-GREEN-REFACTOR testing mindset for skill documentation. No external skill is required; subagents are optional and may be replaced by independent sequential test runs.",
        ).replace("examples/CLAUDE_MD_TESTING.md", "examples/AGENTS_MD_TESTING.md")
        testing.write_text(text, encoding="utf-8")

    persuasion = skills / "writing-skills/persuasion-principles.md"
    if persuasion.exists():
        text = persuasion.read_text(encoding="utf-8")
        text = text.replace("Use tracking: TodoWrite for checklists", "Use tracking: maintain a visible checklist for multi-step work")
        text = text.replace("Checklists without TodoWrite tracking = steps get skipped. Every time.", "Untracked multi-step checklists are easier to skip; keep progress explicit.")
        text = text.replace("Some people find TodoWrite helpful for checklists.", "Some people find explicit checklist tracking helpful.")
        persuasion.write_text(text, encoding="utf-8")

    ref = skills / "mcp-builder/reference/evaluation.md"
    if ref.exists():
        text = ref.read_text(encoding="utf-8")
        text = text.replace("codex-3-7-sonnet-20250219", "gpt-5").replace("codex-3-5-sonnet-20241022", "gpt-5")
        text = text.replace("Codex model to use", "OpenAI model to use").replace("using Codex", "using OpenAI models")
        ref.write_text(text, encoding="utf-8")


def clean(skills: Path) -> None:
    for cache in list(skills.rglob("__pycache__")):
        if cache.is_dir():
            shutil.rmtree(cache)
    for pyc in skills.rglob("*.pyc"):
        pyc.unlink(missing_ok=True)

    legacy_ref = skills / "writing-skills/anthropic-best-practices.md"
    legacy_ref.unlink(missing_ok=True)

    fonts = skills / "canvas-design/canvas-fonts"
    if fonts.exists():
        shutil.rmtree(fonts)
    canvas = skills / "canvas-design/SKILL.md"
    if canvas.exists():
        text = canvas.read_text(encoding="utf-8")
        text = text.replace(
            "Search the `./canvas-fonts` directory.",
            "Use system-installed fonts or user-provided/licensed fonts available in the environment.",
        )
        text = text.replace("`./canvas-fonts`", "system-installed or user-provided fonts")
        text = text.replace("canvas-fonts/", "system-installed fonts / user-provided fonts")
        if "Bundled font binaries are intentionally not included" not in text:
            text += "\n\n## Codex portability note\n\nBundled font binaries are intentionally not included in this Codex distribution. Use system-installed fonts or user-provided/licensed fonts. Do not assume a font file exists inside the skill directory.\n"
        canvas.write_text(text, encoding="utf-8")


def validate(skills: Path) -> None:
    issues = []
    for directory in sorted(p for p in skills.iterdir() if p.is_dir()):
        skill = directory / "SKILL.md"
        if not skill.exists():
            issues.append(f"{directory.name}: missing SKILL.md")
            continue
        text = skill.read_text(encoding="utf-8")
        fm = re.match(r"^---\n(.*?)\n---\n", text, re.S)
        if not fm:
            issues.append(f"{directory.name}: invalid frontmatter")
            continue
        block = fm.group(1)
        name = re.search(r"^name:\s*[\"']?([^\"'\n]+)", block, re.M)
        if not name or name.group(1).strip() != directory.name:
            issues.append(f"{directory.name}: frontmatter name mismatch")
        if not re.search(r"^description:\s*.+$", block, re.M):
            issues.append(f"{directory.name}: missing description")

    blocker = re.compile(r"~/.claude|CLAUDE\.md|superpowers:|from anthropic|Anthropic\(|claude-[0-9]|\./canvas-fonts", re.I)
    for path in skills.rglob("*"):
        if path.is_file() and path.suffix.lower() in TEXT_SUFFIXES:
            try:
                text = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            if blocker.search(text):
                for line_no, line in enumerate(text.splitlines(), 1):
                    if blocker.search(line) and "migration example" not in line.lower():
                        issues.append(f"{path.relative_to(skills)}:{line_no}: stale dependency")

    if issues:
        raise SystemExit("Validation failed:\n" + "\n".join(issues[:100]))

    for path in skills.rglob("*.py"):
        py_compile.compile(str(path), doraise=True)
    for cache in list(skills.rglob("__pycache__")):
        if cache.is_dir():
            shutil.rmtree(cache)
    if shutil.which("node"):
        for path in [*skills.rglob("*.js"), *skills.rglob("*.cjs")]:
            subprocess.run(["node", "--check", str(path)], check=True, capture_output=True)


def pack(skills: Path, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for path in sorted(skills.rglob("*")):
            if path.is_file():
                zf.write(path, Path("skills") / path.relative_to(skills))


def main() -> None:
    parser = argparse.ArgumentParser(description="Build Codex-compatible skills from the original bundle")
    parser.add_argument("input_zip", type=Path, help="Original skills.zip")
    parser.add_argument("-o", "--output", type=Path, default=Path("codex-skills.zip"))
    args = parser.parse_args()
    if not args.input_zip.is_file():
        raise SystemExit(f"Input archive not found: {args.input_zip}")

    script_dir = Path(__file__).resolve().parent
    with tempfile.TemporaryDirectory(prefix="codex-skills-build-") as tmp:
        tmp_path = Path(tmp)
        with zipfile.ZipFile(args.input_zip) as zf:
            safe_extract_zip(zf, tmp_path)
        skills = locate_skills(tmp_path)
        rewrite_text(skills)
        copy_overrides(skills, script_dir)
        clean(skills)
        validate(skills)
        pack(skills, args.output.resolve())
    print(f"Created: {args.output.resolve()}")


if __name__ == "__main__":
    main()
