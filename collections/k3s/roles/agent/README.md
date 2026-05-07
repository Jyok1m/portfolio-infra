# jyok1m.k3s.agent

Installs and configures a k3s **agent** (worker) node on Debian Trixie and joins it to an existing k3s server. Re-runs the install script only when the binary is missing or its version doesn't match `k3s_version`.

## Variables

| Variable                    | Default                         | Description                                                                                  |
| --------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------- |
| `k3s_version`               | `""`                            | k3s version (must match the server). Empty pulls the latest stable from `get.k3s.io`.        |
| `k3s_agent_prerequisites`   | `[curl, ca-certificates]`       | APT packages installed before fetching the install script.                                   |
| `k3s_install_script_url`    | `https://get.k3s.io`            | URL of the official k3s install script.                                                      |
| `k3s_install_script_path`   | `/usr/local/bin/k3s-install.sh` | On-disk path of the downloaded install script.                                               |
| `k3s_agent_server_url`      | `""` (**required**)             | URL of the k3s server (e.g. `https://10.0.0.1:6443`).                                        |
| `k3s_agent_token`           | `""` (**required**)             | Cluster token — must match the server's `k3s_server_token`. Store in ansible-vault.          |
| `k3s_agent_exec_args`       | `""`                            | Extra arguments appended to `INSTALL_K3S_EXEC=agent ...` (e.g. `--node-label workload=app`). |
| `k3s_agent_extra_env`       | `{}`                            | Extra env vars for the install script.                                                       |
| `k3s_agent_service_state`   | `started`                       | Final state of `k3s-agent`. Set to `skip` to leave the service untouched.                    |
| `k3s_agent_service_enabled` | `true`                          | Whether `k3s-agent` is enabled at boot.                                                      |

## Example

```yaml
- name: Join the cluster as a worker
  ansible.builtin.import_role:
    name: jyok1m.k3s.agent
  vars:
    k3s_version: v1.31.4+k3s1
    k3s_agent_server_url: "https://{{ hostvars[groups['k3s_servers'][0]].ansible_host }}:6443"
    k3s_agent_token: "{{ vault_k3s_token }}"
    k3s_agent_exec_args: "--node-label workload=app"
```
