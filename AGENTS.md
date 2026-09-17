# devbox-extras

Devbox plugins, formatting/linting configuration, and certificate utilities for Culture Amp's local development environments.

## Setup

```sh
devbox services up
```

For setup without the interactive TUI (agents, CI):

```sh
devbox services up -b
```

Background logs stream to `.devbox/compose.log` — read with `tail -n 200 .devbox/compose.log`.

## Feedback loop

Preconditions: nothing — lint and test need no running services.

```sh
devbox run verify   # auto-fixes lint, runs tests — use before push
devbox run check    # read-only lint + tests — use after every small change
```

### Available scripts

- `lint` — parallel lint checks (nixpkgs-fmt, statix, shellcheck, shfmt, prettier, rubocop)
- `lint:fix` — auto-fix formatting and linting
- `test` — bats test suite; pass a path to scope: `devbox run test plugins/ca-common`
- `verify` — lint:fix then test
- `check` — lint (read-only) then test

## Gotchas

- The bats tests under `plugins/ca-common/tests/` start their own process-compose instances internally — no services need to be pre-started, but the process-compose binary must be available. Scope to just those tests with `devbox run test plugins/ca-common`.
- `shfmt` and `shellcheck` use `**/*.{sh,bats}` globs that require bash globstar to expand recursively — they may silently match only top-level files in some shells.
