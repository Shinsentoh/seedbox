# Plan: Update repo commands from `docker-compose` to `docker compose`

## Goal

Replace legacy standalone `docker-compose` command invocations with the modern plugin form `docker compose` throughout the repository, while preserving Compose file names (`docker-compose.*.yml`) which are still supported.

## Scope

### Files to change

1. `docker-configuration/clean-all.sh`
   - `docker-compose down --volumes` → `docker compose down --volumes`

2. `docker-configuration/update-all.sh`
   - `docker-compose pull` → `docker compose pull`

3. `docker-configuration/docker-aliases.sh`
   - `docker-compose run $@` → `docker compose run $@`
   - `docker-compose \` (multi-line) → `docker compose \`
   - Update command references in comments (lines 10–12, 132, 139) to `docker compose`
   - File-name references (`docker-compose.$STACK.yml`) remain unchanged

4. `fresh-server-configuration/add-docker.sh`
   - Replace standalone binary install block with plugin install:
     - Remove curl/download/chmod of `/usr/local/bin/docker-compose`
     - Add `apt-get install -y docker-compose-plugin`
     - Update version check to `docker compose version`
     - Update comments accordingly
   - Alternatively keep standalone install but change verification command; recommend plugin form for consistency with upgraded server

5. `README.md`
   - Update prose command references (`docker-compose pull`, `docker-compose down`, `docker-compose` version) to `docker compose`
   - Keep file-name references (`docker-compose.yml`, `docker-compose*`) unchanged

6. `.env.sample`
   - Update comment referencing `docker-compose file` → `docker compose file` (optional, cosmetic)

### Out of scope

- Renaming Compose files (`docker-compose.yml`, `docker-compose.<stack>.yml`) — still valid and recognized by the plugin
- The `local-persist` plugin installation (unrelated)
- Docker CE apt upgrade (already done on server)

## Decisions

- File names stay `docker-compose.*.yml`; only CLI invocations change to `docker compose`.
- `add-docker.sh` should install `docker-compose-plugin` via apt instead of the deprecated standalone binary, matching the upgraded server setup.

## Validation

- `grep -R "docker-compose " --include="*.sh" .` should return only file-name references and comments, no command invocations
- Shell scripts pass `bash -n`
- Aliases still functional: `dc-stack`, `dcu`, `dcd` invoke `docker compose`
- `add-docker.sh` installs plugin and `docker compose version` succeeds

## Risks

- Users with only the standalone binary (no plugin) will break if aliases switch before plugin install; ensure `add-docker.sh` installs the plugin or document prerequisite
- Backward compat: old `docker-compose` command still works if standalone present, but repo standardizes on plugin form
