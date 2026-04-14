# stacklens-helm

Public Helm charts for installing StackLens components.

## Publishing (maintainers)

### Semver releases (`v*` tags)

1. Bump `version` / `appVersion` in `charts/stacklens-platform/Chart.yaml`.
2. Commit and push a **matching** SemVer tag (`v` + chart version), for example `v0.2.0` for chart `0.2.0`.
3. [Release Helm chart](.github/workflows/release.yml) packages the chart (including Bitnami dependencies) and pushes it to **GHCR OCI** at `oci://ghcr.io/<org>/helm`.

The tag must equal the chart `version` (without the leading `v`). The workflow uses **Packages: write** on `GITHUB_TOKEN`.

### Snapshot charts (every `main` image build from stacklens-platform)

When [stacklens-platform CI](https://github.com/getstacklens-ai/stacklens-platform/blob/main/.github/workflows/ci.yml) pushes images on **`main`**, it sends a **repository_dispatch** to this repo (requires **`CROSS_REPO_TOKEN`** on the platform repo with permission to trigger workflows here). [OCI chart snapshot](.github/workflows/oci-snapshot.yml) then publishes a chart version like **`0.0.0-dev.<12-char-sha-prefix>`** with `images.tag` pinned to that commit SHA.

Manual snapshot (same workflow):

```bash
gh workflow run oci-snapshot.yml --repo getstacklens-ai/stacklens-helm -f image_tag=YOUR_SHA
```

Use **semver releases** for anything you treat as stable; snapshots are for continuous integration with fresh images.

## Install from GHCR (OCI)

**Release** chart (example `0.2.0`):

```bash
helm install stacklens oci://ghcr.io/getstacklens-ai/helm/stacklens-platform \
  --version 0.2.0 \
  --namespace stacklens --create-namespace \
  --set ingress.host=app.example.com
```

**Snapshot** chart (version `0.0.0-dev.<sha-prefix>`; default `images.tag` already matches that build):

```bash
helm install stacklens oci://ghcr.io/getstacklens-ai/helm/stacklens-platform \
  --version 0.0.0-dev.abc123def456 \
  --namespace stacklens --create-namespace \
  --set ingress.host=app.example.com
```

## Contents

| Chart | Description |
|-------|-------------|
| [charts/stacklens-platform](charts/stacklens-platform) | Identity, FlowOps, Gateway, UI, Ingress |

## Quickstart (external Postgres + Redis)

```bash
helm upgrade --install stacklens ./charts/stacklens-platform \
  --namespace stacklens --create-namespace \
  --set ingress.host=app.example.com \
  --set secrets.identityDb="Host=...;Database=...;Username=...;Password=..." \
  --set secrets.flowopsDb="Host=...;Database=...;Username=...;Password=..." \
  --set secrets.redis="redis.example.com:6379" \
  --set secrets.jwtSecret="$(openssl rand -base64 32)"
```

StackLens container images use `images.registry` / `images.tag` in `values.yaml` (not `global.imageRegistry`, so Bitnami subcharts are not forced onto GHCR).

## Quickstart (bundled Bitnami Postgres + Redis)

From the chart directory (after `helm dependency update` if you do not commit `charts/*.tgz`):

```bash
helm upgrade --install stacklens . \
  --namespace stacklens --create-namespace \
  --set postgresql.enabled=true \
  --set postgresql.auth.postgresPassword="$(openssl rand -base64 16)" \
  --set redis.enabled=true \
  --set ingress.host=app.example.com \
  --set secrets.jwtSecret="$(openssl rand -base64 32)"
```

Documentation: [https://getstacklens.ai/docs](https://getstacklens.ai/docs)

## `stacklens-platform` values (reference)

| Path | Purpose |
|------|---------|
| `images.registry`, `images.tag`, `images.pullPolicy` | GHCR org + tag for `stacklens-identity`, `stacklens-flowops`, `stacklens-gateway`, `stacklens-ui` |
| `imagePullSecrets` | Pull secrets for those app images |
| `secrets.existingSecret` | If set, chart does not create a Secret; workloads read this name |
| `secrets.create`, `secrets.identityDb`, `secrets.flowopsDb`, `secrets.redis`, `secrets.jwtSecret` | App Secret (`ConnectionStrings__*`, `Jwt__Secret`); DB/Redis strings ignored when bundled subcharts build them |
| `identity.*`, `flowops.*`, `gateway.*`, `ui.*` | Enable replicas, resources, ASP.NET env |
| `gateway.upstreams.identity`, `gateway.upstreams.flowops` | Optional full URLs; empty → in-chart Services |
| `ingress.*` | Host, class, TLS, annotations |
| `postgresql.enabled` | Bitnami PostgreSQL subchart; requires `postgresql.auth.postgresPassword` when `true` |
| `redis.enabled` | Bitnami Redis subchart; tune `redis.auth.*` for passworded Redis |
| `global.namespace` | Optional metadata namespace override (usually use Helm `-n`) |
| `global.postgresql.fullnameOverride` | Override hostname used in generated Postgres connection strings |

Nested keys under `postgresql` / `redis` beyond the table are passed through to the Bitnami charts (see their READMEs).

## License

Chart templates and files in this repository are licensed under **Apache License 2.0** (see `LICENSE`). Container images pulled from `ghcr.io/getstacklens-ai` are proprietary unless otherwise stated.
