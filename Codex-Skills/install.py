#!/usr/bin/env python3
"""Install the Codex skills bundle into user or project .agents/skills."""
from __future__ import annotations

import argparse
import os
import shutil
import stat
import tarfile
import tempfile
import zipfile
from pathlib import Path


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


def safe_extract_tar(tf: tarfile.TarFile, destination: Path) -> None:
    members = tf.getmembers()
    for member in members:
        _safe_target(destination, member.name)
        if member.issym() or member.islnk() or member.isdev():
            raise SystemExit(f"Archive contains unsupported special entry: {member.name}")
    tf.extractall(destination, members=members)


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
                safe_extract_zip(zf, tmp_path)
        elif tarfile.is_tarfile(archive):
            with tarfile.open(archive, "r:*") as tf:
                safe_extract_tar(tf, tmp_path)
        else:
            raise SystemExit(f"Unsupported archive format: {archive}")

        source = tmp_path / "skills"
        if not source.is_dir():
            raise SystemExit("Invalid bundle: expected top-level skills/ directory")

        skill_dirs = sorted(p for p in source.iterdir() if p.is_dir() and (p / "SKILL.md").is_file())
        conflicts = [dest / p.name for p in skill_dirs if (dest / p.name).exists()]
        if conflicts and not args.force:
            names = "\n".join(f"- {path}" for path in conflicts)
            raise SystemExit(
                "No changes were made because these skills already exist:\n"
                f"{names}\n"
                "Re-run with --force to replace existing copies."
            )

        stage_root = Path(tempfile.mkdtemp(prefix=".codex-skills-stage-", dir=dest))
        backup_root = stage_root / ".backup"
        staged_root = stage_root / ".new"
        backup_root.mkdir()
        staged_root.mkdir()

        try:
            for skill_dir in skill_dirs:
                shutil.copytree(skill_dir, staged_root / skill_dir.name)

            replaced: list[str] = []
            installed: list[str] = []
            try:
                for skill_dir in skill_dirs:
                    name = skill_dir.name
                    target = dest / name
                    staged = staged_root / name
                    backup = backup_root / name
                    if target.exists():
                        os.replace(target, backup)
                        replaced.append(name)
                    os.replace(staged, target)
                    installed.append(name)
            except Exception:
                for name in reversed(installed):
                    target = dest / name
                    if target.exists():
                        shutil.rmtree(target)
                for name in reversed(replaced):
                    backup = backup_root / name
                    target = dest / name
                    if backup.exists():
                        os.replace(backup, target)
                raise
        finally:
            shutil.rmtree(stage_root, ignore_errors=True)

    print(f"Installed {len(skill_dirs)} skills to {dest}")
    for skill_dir in skill_dirs:
        print(f"- {skill_dir.name}")


if __name__ == "__main__":
    main()
