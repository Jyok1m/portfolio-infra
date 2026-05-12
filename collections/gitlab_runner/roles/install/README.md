# jyok1m.gitlab_runner.install

Installs the official GitLab Runner package from `packages.gitlab.com`, registers a single docker-executor runner against gitlab.com via a UI-issued authentication token, and runs it as a system-mode service.

## Behavior

The role lays down:

| Path                                         | Purpose                                                     |
| -------------------------------------------- | ----------------------------------------------------------- |
| `/etc/apt/keyrings/gitlab-runner.gpg`        | Signing key for the GitLab Runner apt repo                  |
| `/etc/apt/sources.list.d/gitlab-runner.list` | Pinned apt source                                           |
| `/etc/gitlab-runner/config.toml`             | Runner configuration (`0600 root:root`, contains the token) |
| `gitlab-runner` systemd service              | System-mode daemon, runs as the `gitlab-runner` user        |

The `gitlab-runner` system user is added to the `docker` group so the executor can reach the host docker socket — this requires Docker to already be installed (e.g. via `jyok1m.docker_compose.install`).

## Token model

This role targets gitlab.com's modern authentication-token flow:

1. In gitlab.com → **Settings → CI/CD → Runners** → create a new runner. Set the description, tags, and lock state in the UI.
2. Copy the resulting `glrt-...` token.
3. Pass it as `gitlab_runner_token` (from vault). The role writes it directly into `config.toml` — no `gitlab-runner register` subprocess.

Re-runs are pure template diff: re-rendering the same token is a no-op; rotating the token replaces the file and restarts the service.

## Variables

| Variable                          | Default                              | Description                                                                 |
| --------------------------------- | ------------------------------------ | --------------------------------------------------------------------------- |
| `gitlab_runner_token`             | _(required)_                         | `glrt-...` auth token from the gitlab.com UI (vault).                       |
| `gitlab_runner_url`               | `https://gitlab.com/`                | GitLab instance URL.                                                        |
| `gitlab_runner_name`              | `{{ ansible_hostname }}-docker`      | Local runner name (UI controls the public description).                     |
| `gitlab_runner_concurrent`        | `4`                                  | Max parallel jobs across all runners on this host.                          |
| `gitlab_runner_check_interval`    | `0`                                  | Seconds between job polls (0 = default).                                    |
| `gitlab_runner_log_level`         | `info`                               | Runner log level.                                                           |
| `gitlab_runner_session_timeout`   | `1800`                               | Session server timeout (seconds), used by interactive `gitlab-runner exec`. |
| `gitlab_runner_executor`          | `docker`                             | Executor type.                                                              |
| `gitlab_runner_default_image`     | `docker:24`                          | Image used when a job doesn't pin `image:`.                                 |
| `gitlab_runner_privileged`        | `true`                               | Required for docker-in-docker / buildx multiarch builds.                    |
| `gitlab_runner_pull_policy`       | `if-not-present`                     | Docker image pull policy.                                                   |
| `gitlab_runner_shm_size`          | `0`                                  | `/dev/shm` size in bytes (0 = docker default).                              |
| `gitlab_runner_volumes`           | `["/cache"]`                         | Extra volumes mounted into every job container.                             |
| `gitlab_runner_network_mode`      | `""`                                 | Docker network mode (empty = bridge).                                       |
| `gitlab_runner_extra_hosts`       | `[]`                                 | Extra `/etc/hosts` entries (`["host:ip", ...]`).                            |
| `gitlab_runner_environment`       | `[]`                                 | Env vars injected into every job (`["KEY=val", ...]`).                      |
| `gitlab_runner_apt_distribution`  | `{{ ansible_distribution_release }}` | Debian codename used in the apt repo URL.                                   |
| `gitlab_runner_service_state`     | `started`                            | Final systemd state (`stopped` in tests where the token is fake).           |
| `gitlab_runner_service_enabled`   | `true`                               | Whether the unit is enabled at boot.                                        |
| `gitlab_runner_join_docker_group` | `true`                               | Add `gitlab-runner` user to the host `docker` group.                        |

## DinD / buildx multi-arch

With `gitlab_runner_privileged: true` (default), a `.gitlab-ci.yml` using `docker:24-dind` as a service works out of the box. No `/certs/client` volume is needed if the job sets `DOCKER_TLS_CERTDIR=""`. Example job header that's known to work with this runner:

```yaml
variables:
  DOCKER_HOST: tcp://docker:2375
  DOCKER_TLS_CERTDIR: ""
default:
  image: docker:24
  services:
    - name: docker:24-dind
      alias: docker
      command: ["--tls=false"]
```
