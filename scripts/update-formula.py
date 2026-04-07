#!/usr/bin/env python3

import json
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Optional


def die(message: str):
    print(message, file=sys.stderr)
    raise SystemExit(1)


def fetch_text(url: str) -> str:
    try:
        with urllib.request.urlopen(url) as response:
            return response.read().decode("utf-8")
    except urllib.error.URLError as exc:
        die(f"failed to fetch {url}: {exc}")


def formula_class_name(formula: str) -> str:
    parts = [part.capitalize() for part in re.split(r"[-_]+", formula) if part]
    if not parts:
        die("formula name must not be empty")
    return "".join(parts)


def extract_release_data(release_json: dict, repository: str) -> tuple[str, str]:
    tag_name = release_json.get("tag_name", "")
    if not tag_name:
        die(f"latest release tag not found for {repository}")

    for asset in release_json.get("assets", []):
        if asset.get("name") == "checksums-sha256.txt":
            checksums_url = asset.get("browser_download_url", "")
            if checksums_url:
                return tag_name, checksums_url

    die(f"checksums-sha256.txt not found in latest release for {repository}")


def extract_checksum(checksums_text: str, asset_name: str, formula: str, repository: str) -> str:
    pattern = rf"^([0-9a-f]{{64}})\s+{re.escape(asset_name)}$"
    match = re.search(pattern, checksums_text, re.MULTILINE)
    if not match:
        die(f"missing expected checksum for {formula} asset {asset_name} in latest release for {repository}")
    return match.group(1)


def maybe_extract_checksum(checksums_text: str, asset_name: str) -> Optional[str]:
    pattern = rf"^([0-9a-f]{{64}})\s+{re.escape(asset_name)}$"
    match = re.search(pattern, checksums_text, re.MULTILINE)
    return match.group(1) if match else None


def extract_existing_value(formula_text: str, field: str, default: str) -> str:
    match = re.search(rf'^\s*{field}\s+"(.*)"$', formula_text, re.MULTILINE)
    return match.group(1) if match else default


def main() -> int:
    if len(sys.argv) != 3:
        die(f"usage: {sys.argv[0]} <formula> <owner/repo>")

    formula = sys.argv[1]
    repository = sys.argv[2]

    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parent
    template_path = script_dir / "formula.rb.tmpl"
    formula_path = repo_root / "Formula" / f"{formula}.rb"

    if not template_path.is_file():
        die(f"formula template not found: {template_path}")

    release_text = fetch_text(f"https://api.github.com/repos/{repository}/releases/latest")
    release_json = json.loads(release_text)
    tag_name, checksums_url = extract_release_data(release_json, repository)
    checksums_text = fetch_text(checksums_url)

    version = tag_name[1:] if tag_name.startswith("v") else tag_name
    darwin_arm64_sha = extract_checksum(checksums_text, f"{formula}-darwin-arm64", formula, repository)
    darwin_amd64_sha = maybe_extract_checksum(checksums_text, f"{formula}-darwin-amd64")
    linux_amd64_sha = extract_checksum(checksums_text, f"{formula}-linux-amd64", formula, repository)
    linux_arm64_sha = extract_checksum(checksums_text, f"{formula}-linux-arm64", formula, repository)

    desc = f"{formula} CLI"
    license_name = "MIT"
    if formula_path.is_file():
        formula_text = formula_path.read_text(encoding="utf-8")
        desc = extract_existing_value(formula_text, "desc", desc)
        license_name = extract_existing_value(formula_text, "license", license_name)

    macos_intel_block = ""
    if darwin_amd64_sha:
        macos_intel_block = (
            "\n"
            "    if Hardware::CPU.intel?\n"
            f'      url "https://github.com/{repository}/releases/download/{tag_name}/{formula}-darwin-amd64"\n'
            f'      sha256 "{darwin_amd64_sha}"\n'
            "    end"
        )

    rendered = template_path.read_text(encoding="utf-8")
    replacements = {
        "__FORMULA_CLASS__": formula_class_name(formula),
        "__FORMULA__": formula,
        "__REPOSITORY__": repository,
        "__TAG_NAME__": tag_name,
        "__VERSION__": version,
        "__DARWIN_ARM64_SHA__": darwin_arm64_sha,
        "__MACOS_INTEL_BLOCK__": macos_intel_block,
        "__LINUX_AMD64_SHA__": linux_amd64_sha,
        "__LINUX_ARM64_SHA__": linux_arm64_sha,
        "__DESC__": desc,
        "__LICENSE__": license_name,
    }

    for old, new in replacements.items():
        rendered = rendered.replace(old, new)

    formula_path.write_text(rendered, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
