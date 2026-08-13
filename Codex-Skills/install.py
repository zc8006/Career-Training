#!/usr/bin/env python3
"""Install the Codex skills bundle into user or project .agents/skills."""
from __future__ import annotations

import argparse
import shutil
import tempfile
import tarfile
import zipfile
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Install Codex-compatible skills")
    parser.add_argument("archive", type=Path, help="Path to codex-skills.zip or a tar archive")
    parser.add_argument("--project", action="store_true", help="Install into ./.agents/skills")
    parser.add_argument("--dest", type=Path, help="Explicit skills destination")
    parser.add_argument("--force", action="store_true", help="Replace existing skills with the same names")
    args = parser.parse_args()

    archive = args.archive.expanduser().resolve()
    if not archive.is_file():
        raise SystemExit(f"Archive not found: {archive}")

    if args.dest:
        dest = args.dest.expanduser().resolve()
    elif args.project:
        dest = (Path.cwd() / ".agents" / "skills").resolve()
    else:
        dest = (Path.home() / ".agents" / "skills").resolve()

    dest.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="codex-skills-") as tmp:
        tmp_path = Path(tmp)
        if zipfile.is_zipfile(archive):
            with zipfile.ZipFile(archive) as zf:
                zf.extractall(tmp_path)
        elif tarfile.is_tarfile(archive):
            with tarfile.open(archive, "r:*") as tf:
                tf.extractall(tmp_path, filter="data")
        else:
            raise SystemExit(f"Unsupported archive format: {archive}")
        source = tmp_path / "skills"
        if not source.is_dir():
            raise SystemExit("Invalid bundle: expected top-level skills/ directory")

        installed = []
        for skill_dir in sorted(p for p in source.iterdir() if p.is_dir()):
            if not (skill_dir / "SKILL.md").is_file():
                continue
            target = dest / skill_dir.name
            if target.exists():
                if not args.force:
                    raise SystemExit(
                        f"Skill already exists: {target}\n"
                        "Re-run with --force to replace existing copies."
                    )
                shutil.rmtree(target)
            shutil.copytree(skill_dir, target)
            installed.append(skill_dir.name)

    print(f"Installed {len(installed)} skills to {dest}")
    for name in installed:
        print(f"- {name}")


if __name__ == "__main__":
    main()
