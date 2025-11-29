# MkDocs Quick Start

Launch and validate the documentation site in minutes. Pair this with `MKDOCS_SETUP.md` for deeper configuration notes.

## One-Minute Setup

```bash
python -m venv .venv-docs
source .venv-docs/bin/activate
pip install -r requirements-docs.txt
```

## Serve Locally

```bash
# Live reload at http://127.0.0.1:8000
mkdocs serve --strict
```

## Build & Validate

```bash
# Clean build with link and ref checks
mkdocs build --clean --strict
```

## Publish to GitHub Pages

```bash
# Push static site to gh-pages
mkdocs gh-deploy --force
```

Automated deploys run via `.github/workflows/deploy-docs.yml` on pushes to `main`.

## Authoring Guardrails
- Add new pages under `docs/`; module content is already available through symlinks in `docs/modules/` and related directories.
- Keep navigation in sync by updating `nav:` within `mkdocs.yml`.
- Use relative links (for example, `modules/B_mock_exam/exam_01/instructions.md`) so content works both locally and on the published site.
- Prefer fenced code blocks with language hints and use Material admonitions (`!!! note`, `!!! tip`) for callouts.
- Run `mkdocs serve --strict` before opening a PR to catch broken links or missing assets.

## Common Fixes
- Missing theme or extensions: `pip install -r requirements-docs.txt`
- Stale output: `rm -rf site/` then `mkdocs build --clean`
- Navigation 404s: confirm the file exists under `docs/` (or a symlink target) and matches the case used in `mkdocs.yml`
