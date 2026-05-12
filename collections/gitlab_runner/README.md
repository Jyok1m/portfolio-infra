# jyok1m.gitlab_runner

Ansible collection that installs a system-mode GitLab Runner with the docker executor on Debian Trixie, ready to pick up jobs from gitlab.com.

## Contents

| Role                           | Description                                                                                                                        |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `jyok1m.gitlab_runner.install` | Installs the official `gitlab-runner` package, renders `config.toml` with a UI-issued auth token, and runs it as a system service. |

## Requirements

- Ansible `>= 2.20`
- Debian Trixie target host with `apt`
- Docker Engine on the target host — the runner talks to the host docker socket. Pair with `jyok1m.docker_compose.install` if Docker is not already installed.
- A GitLab Runner authentication token (`glrt-...`) issued from gitlab.com → **Settings → CI/CD → Runners**.

## Installation

```bash
ansible-galaxy collection install jyok1m.gitlab_runner
```

## Quick start

```yaml
- name: Install the project's GitLab Runner
  ansible.builtin.import_role:
    name: jyok1m.gitlab_runner.install
  vars:
    gitlab_runner_token: "{{ vault_gitlab_runner_token }}"
    gitlab_runner_name: "ovh-runner-docker"
```

That's it. With the defaults (`privileged: true`, `image: docker:24`, `volumes: ["/cache"]`), a typical buildx multi-arch CI job using `docker:24-dind` as a service will run unchanged.

## License

MIT
