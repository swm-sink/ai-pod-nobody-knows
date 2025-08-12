# Security Policy

## Reporting a Vulnerability

If you discover a vulnerability or a leaked secret, please open a private issue or contact the repository owner directly. Do not open a public issue with sensitive details.

## Secrets Handling

- Never commit API keys or secrets. Use `.env` (git-ignored) with values copied from `.env.example`.
- Local-only scripts are placed under `.claude/` and are git-ignored by default.
- GitHub Actions run Gitleaks on pushes and pull requests to help prevent secret leaks.

## Developer Workflow

- Install pre-commit hooks: `pip install -r dev-requirements.txt && pre-commit install`.
- Hooks include basic hygiene and `detect-secrets` scanning against the committed baseline.
- Update the baseline when adding new legitimate tokens: `detect-secrets scan > .secrets.baseline && git add .secrets.baseline`.


