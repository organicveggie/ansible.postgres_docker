# Ansible Role: PostgreSQL on Docker <!-- omit in toc -->

[![github](https://github.com/organicveggie/ansible.postgres_docker/workflows/Molecule/badge.svg)](https://github.com/organicveggie/ansible.postgres_docker/actions/workflows/molecule.yml)
[![github](https://github.com/organicveggie/ansible.postgres_docker/workflows/Lint/badge.svg)](https://github.com/organicveggie/ansible.postgres_docker/actions/workflows/lint.yml)
[![Issues](https://img.shields.io/github/issues/organicveggie/ansible.postgres_docker.svg)](https://github.com/organicveggie/ansible.postgres_docker/issues/)
[![PullRequests](https://img.shields.io/github/issues-pr-closed-raw/organicveggie/ansible.postgres_docker.svg)](https://github.com/organicveggie/ansible.postgres_docker/pulls/)
[![Last commit](https://img.shields.io/github/last-commit/organicveggie/ansible.postgres_docker?logo=github)](https://github.com/organicveggie/ansible.postgres_docker/commits/main)

An [Ansible](https://www.ansible.com/) role to setup and run the [PostgreSQL](https://www.postgresql.org/)
[Docker](http://www.docker.com) [container](https://hub.docker.com/_/postgres).

## Contents <!-- omit in toc -->

- [Requirements](#requirements)
- [Role Variables](#role-variables)
- [Dependencies](#dependencies)
- [Example Playbooks](#example-playbooks)
  - [Create a network](#create-a-network)
  - [Custom name with bind mounts](#custom-name-with-bind-mounts)
  - [Initialization scripts](#initialization-scripts)
- [License](#license)
- [Author Information](#author-information)

## Requirements

Requires Docker. Reecommended role for Docker installation: `geerlingguy.docker`.

## Role Variables

- `postgres_docker_name`: Name of the Docker container.
- `postgres_docker_admin_password`: Superuser password.
- `postgres_docker_initscripts`: Optional initialization scripts to copy into the PostgreSQL Docker container. These can be `.sql`, `sql.gz`, or `.sh` files. They *must* already exist on the target system, so that this role can copy them into the Docker container.
  
  After container calls `initdb` to create the default `postgres` user and database, it will run any `*.sql` files, run any executable `*.sh` scripts, and source any non-executable `*.sh` scripts  before starting the service. Scripts are only run if you start the container with a data directory that is empty; any pre-existing database will be left untouched on container startup. One common problem is that if one of your scripts fails and your orchestrator restarts the container with the already initialized data directory, it will not continue on with your scripts.

  Initialization files will be executed in sorted name order as defined by the current locale, which defaults to `en_US.utf8`. Any `*.sql` files will be executed by `POSTGRES_USER`, which defaults to the `postgres` superuser. It is recommended that any `psql` commands that are run inside of a `*.sh` script be executed as `POSTGRES_USER` by using the `--username "$POSTGRES_USER"` flag. This user will be able to connect without a password due to the presence of `trust` authentication for Unix socket connections made inside the container.
- `postgres_docker_use_volumes`: Whether or not to use Docker volumes. True will create dedicated two Docker volumes:
  - One for the config files mounted at `/etc/postgresql`.
  - One for the data files mounted at `/var/lib/postgresql/data`.
- `postgres_docker_memory`: Amount of memory to allocate to the PostgreSQL container.
- `postgres_docker_cpu`: Number of vCPUs to allocate to the PostgreSQL container.
- `postgres_docker_network_create`: Whether or not to create a Docker network for the PostgreSQL container. True will create a network specifically for this container. False will not create a network, but will automatically join the network specified in `postgres_docker_network_name`.
- `postgres_docker_network_name`: Name of the Docker network to join. Required. Especially useful if `postgres_docker_network_create` is set to false.
- `postgres_docker_image`: Name and label of the Docker image to use.
- `postgres_docker_available_externally`: Whether or not to enable in [Traefik Proxy](https://doc.traefik.io/traefik/).

See [defaults/main.yml](defaults/main.yml) for a complete list.

## Dependencies

None.

## Example Playbooks

### Create a network

```yaml
- hosts: all
  vars:
    postgres_docker_network_create: true
    postgres_docker_memory: "2GB"
    postgres_docker_cpu: "2"
  roles:
    - geerlingguy.docker
    - organicveggie.postgres_docker
```

### Custom name with bind mounts

```yaml
- hosts: all
  vars:
    postgres_docker_name: "pgsql-example"
    postgres_docker_use_volumes: false
  roles:
    - geerlingguy.docker
    - organicveggie.postgres_docker
```

### Initialization scripts

Shell script to setup new user and database: `01_create_example.sh`

```shell
#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES" --dbname "molecule" <<-EOSQL
    CREATE USER example;
    CREATE DATABASE exampledb;
    GRANT ALL PRIVILEGES ON DATABASE exampledb TO example;
    CREATE TABLE test (
        id int CONSTRAINT id_pk PRIMARY KEY
    );
    INSERT INTO test VALUES (42), (54);
EOSQL
```

Playbook:

```yaml
- hosts: all
  roles:
    - geerlingguy.docker

- hosts: all

vars:
    postgres_docker_initscripts:
        - "/tmp/01_create_example.sh"

  tasks:
    - name: Copy init script
      ansible.builtin.copy:
        src: "files/01_create_example.sh"
        dest: "/tmp"
        mode: "755"

  roles:
    - organicveggie.postgres_docker
```

## License

[Apache](LICENSE)

## Author Information

[Sean Laurent](http://github/organicveggie)
