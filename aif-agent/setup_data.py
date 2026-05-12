"""
setup_data.py — Run once before local development or CF push.

Copies all data files from the parent lsa_aif_doc/ directory into data/:
  data/xlsx/     ← all *.xlsx files
  data/docs/     ← all *.md files
  data/abapgit/  ← full #THKR#AIF_* abapgit repository

Usage:
  python setup_data.py

For CF deployment, run this locally first, then:
  cf push
"""

import shutil
import sys
from pathlib import Path

HERE = Path(__file__).parent          # aif-agent/
PARENT = HERE.parent                  # lsa_aif_doc/
DATA = HERE / "data"


def copy_xlsx():
    dst = DATA / "xlsx"
    dst.mkdir(parents=True, exist_ok=True)
    copied = 0
    for f in sorted(PARENT.glob("*.xlsx")):
        shutil.copy2(f, dst / f.name)
        print(f"  [xlsx]  {f.name}")
        copied += 1
    if copied == 0:
        print("  [xlsx]  WARNING: no .xlsx files found in parent directory")
    return copied


def copy_docs():
    dst = DATA / "docs"
    dst.mkdir(parents=True, exist_ok=True)
    copied = 0
    for f in sorted(PARENT.glob("*.md")):
        shutil.copy2(f, dst / f.name)
        print(f"  [docs]  {f.name}")
        copied += 1
    if copied == 0:
        print("  [docs]  WARNING: no .md files found in parent directory")
    return copied


def copy_abapgit():
    dst = DATA / "abapgit"
    dst.mkdir(parents=True, exist_ok=True)

    # Find the abapgit repo folder (starts with #THKR#AIF_)
    repos = [d for d in PARENT.iterdir() if d.is_dir() and d.name.startswith("#THKR#AIF_")]
    if not repos:
        print("  [abap]  WARNING: no #THKR#AIF_* folder found in parent directory")
        return 0

    copied = 0
    for repo in repos:
        target = dst / repo.name
        if target.exists():
            shutil.rmtree(target)
        shutil.copytree(repo, target)
        abap_count = len(list(target.rglob("*.abap")))
        print(f"  [abap]  {repo.name}  ({abap_count} .abap files)")
        copied += 1
    return copied


def main():
    print(f"Source : {PARENT}")
    print(f"Target : {DATA}")
    print()

    x = copy_xlsx()
    d = copy_docs()
    a = copy_abapgit()

    print()
    print(f"Done — xlsx:{x}  docs:{d}  abapgit repos:{a}")

    if x == 0 or a == 0:
        print("\nWARNING: some data sources are missing. Check paths above.")
        sys.exit(1)


if __name__ == "__main__":
    main()
