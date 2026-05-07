# jyok1m.docker_compose.install

Installs Docker Engine and the Compose v2 plugin from the official Docker apt repository on Debian Trixie. The role adds the GPG key under `/etc/apt/keyrings/`, drops a deb822 source under `/etc/apt/sources.list.d/`, and installs the canonical package set.

## Variables

| Variable                          | Default                                                                          | Description                                          |
| --------------------------------- | -------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `docker_install_prerequisites`    | `[ca-certificates, curl]`                                                        | Packages installed before adding the Docker repo.    |
| `docker_install_keyring_path`     | `/etc/apt/keyrings/docker.asc`                                                   | Where the Docker GPG key is stored.                  |
| `docker_install_signing_key_url`  | `https://download.docker.com/linux/debian/gpg`                                   | URL of the Docker GPG signing key.                   |
| `docker_install_repo_url`         | `https://download.docker.com/linux/debian`                                       | Docker apt repository base URL.                      |
| `docker_install_repo_components`  | `stable`                                                                         | Repo components.                                     |
| `docker_install_sources_path`     | `/etc/apt/sources.list.d/docker.sources`                                         | Path of the deb822 source file.                      |
| `docker_install_packages`         | `[docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin]` | Packages installed from the Docker repo.    |
| `docker_install_service_state`    | `started`                                                                        | Final state of the `docker` service.                 |
| `docker_install_service_enabled`  | `true`                                                                           | Whether `docker` is enabled at boot.                 |
| `docker_install_users`            | `[]`                                                                             | List of users to add to the `docker` group.          |

## Example

This is a **role**, not a module. Invoke it with `import_role` (or `include_role`) and pass variables under `vars:`.

```yaml
- name: Install Docker
  ansible.builtin.import_role:
    name: jyok1m.docker_compose.install
  vars:
    docker_install_users: [deploy, jenkins]
```
