# jyok1m.k3s.server

Installs and configures a k3s **server** (control plane) node on Debian Trixie via the official `get.k3s.io` install script. The role is idempotent: it only re-runs the script when the binary is missing or its version doesn't match the requested `k3s_version`.

## Variables

| Variable                     | Default                         | Description                                                                                                                                                                                                 |
| ---------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `k3s_version`                | `""`                            | k3s version (e.g. `v1.31.4+k3s1`). Empty pulls the latest stable from `get.k3s.io`.                                                                                                                         |
| `k3s_server_prerequisites`   | `[curl, ca-certificates]`       | APT packages installed before fetching the install script.                                                                                                                                                  |
| `k3s_install_script_url`     | `https://get.k3s.io`            | URL of the official k3s install script.                                                                                                                                                                     |
| `k3s_install_script_path`    | `/usr/local/bin/k3s-install.sh` | On-disk path of the downloaded install script.                                                                                                                                                              |
| `k3s_server_token`           | `""`                            | Shared cluster token. Empty → k3s generates one on first start; the role then reads it from `/var/lib/rancher/k3s/server/node-token` and prints it once for vaulting. Set → passed verbatim as `K3S_TOKEN`. |
| `k3s_server_exec_args`       | `""`                            | Extra arguments appended to `INSTALL_K3S_EXEC=server ...` (e.g. `--disable=traefik`).                                                                                                                       |
| `k3s_server_extra_env`       | `{}`                            | Extra env vars for the install script (e.g. `INSTALL_K3S_SKIP_START: "true"`).                                                                                                                              |
| `k3s_server_service_state`   | `started`                       | Final state of the `k3s` systemd service. Set to `skip` to leave the service untouched.                                                                                                                     |
| `k3s_server_service_enabled` | `true`                          | Whether `k3s` is enabled at boot.                                                                                                                                                                           |

## Example

This is a **role**, not a module — invoke it with `import_role` (or `include_role`).

```yaml
- name: Install the k3s server
  ansible.builtin.import_role:
    name: jyok1m.k3s.server
  vars:
    k3s_version: v1.31.4+k3s1
    k3s_server_token: "{{ k3s_token }}"
    k3s_server_exec_args: "--disable=traefik --tls-san={{ ansible_default_ipv4.address }}"
```

## How the token is handled

If you don't pass `k3s_server_token`, k3s generates one on first start and writes it to `/var/lib/rancher/k3s/server/node-token`. After install the role:

1. Slurps that file and exposes the value as the host fact `k3s_server_node_token`.
2. Prints it once via `debug` so you can copy it into your vault (e.g. `k3s_token` in `group_vars/<group>/vault.yml`).

On subsequent runs the file already exists, the value is unchanged, and the install script does not re-run — so the print is harmless but you can silence it by passing the vaulted token as `k3s_server_token` (the debug task is gated on `k3s_server_token | length == 0`).

Other plays in the same run can still join agents using `hostvars[groups['k3s_servers'][0]].k3s_server_node_token` without any vault round-trip — useful on the very first provisioning run, before you've persisted the token.
