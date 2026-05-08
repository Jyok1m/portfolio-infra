# jyok1m.backups

Ansible collection for scheduled, encrypted, off-site backups of containerized data services on Debian Trixie. Dumps are driven by systemd timers, archives are pushed to a restic repository, and a sibling restore role brings a snapshot back into a running container.

## Contents

| Role                           | Description                                                                                                                                                                                                    |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jyok1m.backups.mongo_dump`    | Installs restic, renders a dump script, and schedules it via a systemd timer. The script runs `mongodump` against a container Mongo and pushes the archive to a restic repository with configurable retention. |
| `jyok1m.backups.mongo_restore` | Installs restic and a restore script that fetches a given snapshot from the restic repository and pipes it into `mongorestore` against a target container Mongo. Manual invocation only — no timer.            |

## Requirements

- Ansible `>= 2.20`
- Collection `community.docker >= 5.2.0` (installed automatically)
- Debian Trixie target host with `apt`
- Docker Engine on the target host (the dump/restore roles do **not** install Docker — pair with `jyok1m.docker_compose.install` if needed)
- A reachable restic repository (S3-compatible — OVH Object Storage, AWS, MinIO, … — or B2, SFTP, REST server) and its access credentials

## Installation

```bash
ansible-galaxy collection install jyok1m.backups
```

## Quick start

### Schedule daily Mongo dumps for an app

```yaml
- name: Schedule <app_name>-db dumps
  ansible.builtin.import_role:
    name: jyok1m.backups.mongo_dump
  vars:
    mongo_dump_name: <app_name>
    mongo_dump_container: <app_name>-db
    mongo_dump_network: <app_name>-internal
    mongo_dump_username: "{{ <app_name>_db_user }}"
    mongo_dump_password: "{{ <app_name>_db_password }}"
    mongo_dump_restic_repo: "s3:https://s3.gra.io.cloud.ovh.net/<bucket>"
    mongo_dump_restic_password: "{{ restic_password }}"
    mongo_dump_restic_env:
      AWS_ACCESS_KEY_ID: "{{ s3_access_key_<app_name> }}"
      AWS_SECRET_ACCESS_KEY: "{{ s3_secret_key<app_name> }}"
```

OVH Object Storage exposes an S3-compatible endpoint per region (e.g. `s3.gra.io.cloud.ovh.net` for Gravelines, `s3.sbg.io.cloud.ovh.net` for Strasbourg, `s3.bhs.io.cloud.ovh.net` for Beauharnois). The bucket name and credentials come from the OVH user you created for the bucket.

The role lays down:

- `/usr/local/bin/mongo-dump-<app_name>.sh` — the dump script
- `/etc/mongo-dump-<app_name>.env` — restic credentials (root-readable, `0600`)
- `/etc/systemd/system/mongo-dump-<app_name>.service` — oneshot unit
- `/etc/systemd/system/mongo-dump-<app_name>.timer` — schedule (default: daily, randomized 30 min)

### Restore a snapshot

```yaml
- name: Install <app_name> restore tooling
  ansible.builtin.import_role:
    name: jyok1m.backups.mongo_restore
  vars:
    mongo_restore_name: <app_name>
    mongo_restore_container: <app_name>-db
    mongo_restore_network: <app_name>-internal
    mongo_restore_username: "{{ <app_name>_db_user }}"
    mongo_restore_password: "{{ <app_name>_db_password }}"
    mongo_restore_restic_repo: "s3:https://s3.gra.io.cloud.ovh.net/<bucket>"
    mongo_restore_restic_password: "{{ restic_password }}"
    mongo_restore_restic_env:
      AWS_ACCESS_KEY_ID: "{{ s3_access_key_<app_name> }}"
      AWS_SECRET_ACCESS_KEY: "{{ s3_secret_key<app_name> }}"
```

Then on the host:

```bash
sudo mongo-restore-<app_name>.sh latest          # restore the most recent snapshot
sudo mongo-restore-<app_name>.sh <snapshot-id>   # restore a specific snapshot
sudo mongo-restore-<app_name>.sh latest --drop   # drop existing collections first
```

## License

MIT
