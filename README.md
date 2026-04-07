# homebrew-tap

Shared Homebrew tap for realxen command-line tools.

## Purpose

This repository hosts custom Homebrew formulae under `Formula/`.

Example install flow:

```bash
brew install realxen/tap/cartograph
```

## Expected layout

```text
Formula/
  cartograph.rb
```

## Release automation

After publishing a GitHub release, run the `Update formula` workflow manually.
It reads the GitHub repository from the existing formula, fetches the latest
release, downloads `checksums-sha256.txt`, and updates the formula
automatically.

You can also run the updater locally:

```bash
python3 ./scripts/update-formula.py cartograph
```

## Current formulae

- `cartograph`
