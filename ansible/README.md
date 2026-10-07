# ansible/

Aprovisionamiento del home lab. El playbook es **convergente**: está pensado
para correrse repetidamente, también sobre la máquina que lo ejecuta
(`ansible_connection=local`), para añadir apps nuevas o reconciliar config.

## Puesta en marcha (una vez)

```bash
sudo apt install ansible          # o: pipx install ansible
cd ansible/
cp inventory.ini.example inventory.ini
ansible-galaxy collection install -r requirements.yml
```

## Uso diario

```bash
cd ansible/
ansible-playbook main.yml --check --diff -K   # dry-run: SIEMPRE primero
ansible-playbook main.yml -K                  # aplicar
```

No hace falta `-i inventory.ini` (lo pone `ansible.cfg`) ni `-e @vars.yml`
(ver más abajo). `-K` pide la contraseña de sudo.

### Por tags

```bash
ansible-playbook main.yml --tags dotfiles -K  # dev tools, symlinks, shell
ansible-playbook main.yml --tags docker -K
ansible-playbook main.yml --tags upgrade -K   # apt upgrade (opt-in, ver abajo)
```

Tags disponibles: `system`, `dotfiles`, `git`, `docker`, `security`, `backups`,
y `upgrade`.

## Añadir una app nueva

La mayoría de apps son una línea en la lista de paquetes del role que toque:

| Qué es                        | Dónde                                     |
| ----------------------------- | ----------------------------------------- |
| Paquete de infra (servidor)   | `roles/system/defaults/main.yml`          |
| Dev tool personal             | `roles/dotfiles/defaults/main.yml`        |
| App con repo apt propio       | Nuevo `roles/system/tasks/<app>.yml` + `import_tasks` |
| App de cargo (Rust)           | `dotfiles_cargo_packages` en `roles/dotfiles/defaults/main.yml` |
| App de Go / curl              | `roles/dotfiles/tasks/main.yml`           |

Para repos apt propios, copia el patrón de `roles/system/tasks/glow.yml`
(keyring en `/etc/apt/keyrings`, `apt_repository`, `apt`), y recuerda
`become: true` en cada tarea que escriba en `/etc`.

## Variables

Las variables viven en `group_vars/home_lab.yml` (común) y
`host_vars/<host>.yml` (por máquina), con los valores por defecto de cada role
en `roles/*/defaults/main.yml`. Precedencia: `defaults` < `group_vars` <
`host_vars`.

### Las dos raíces

| Variable         | Valor                 | Qué es                                                   |
| ---------------- | --------------------- | -------------------------------------------------------- |
| `workspace_root` | `~/workspace`         | Cajón: `development/`, `dotfiles/`, `homelab/`, `temp/`   |
| `home_lab_root`  | `~/workspace/homelab` | El home lab: `docker/`, `notes/`, `backups/`, `scripts/`  |

No son lo mismo y conviene no confundirlas: `home_lab_root` tiene aquí el mismo
significado que la variable homónima de `terraform/` (`services/`, `scripts/`,
`obsidian/`). Los dotfiles cuelgan del *workspace*, no del home lab.

> **Nota histórica:** antes había un `vars.yml` que se pasaba con
> `-e @vars.yml`. Las extra-vars (`-e`) tienen la precedencia MÁS ALTA de
> Ansible, así que impedían ajustar nada por máquina. Por eso se migró.

## Cosas que NO son idempotentes a propósito

### `apt upgrade`

La tarea lleva `tags: [never, upgrade]`: no corre en ejecuciones normales. Un
upgrade desatendido no debe pasar cuando lo único que querías era añadir una
app. Para actualizar a propósito: `--tags upgrade`.

### Backups

`backups_enabled` controla solo el cron. El script se despliega siempre, y
comprueba en tiempo de ejecución que el remote de rclone exista, así que no
llena el log de errores mientras `rclone config` siga pendiente:

```bash
rclone config          # crear el remote, una vez, a mano
```

Los orígenes son pares `src`/`dest` explícitos (no `basename`) para que dos
rutas distintas no se sobreescriban en el remote.

## Particularidades por máquina

### UFW y acceso remoto

`security_ufw_allowed_ports` y `security_ufw_trusted_interfaces` se ajustan en
`host_vars/`. **Importante:** la política `deny incoming` aplica también a
`tailscale0`, así que una máquina que se administre por Tailscale necesita esa
interfaz en `security_ufw_trusted_interfaces` o se pierde el acceso al
reiniciar. El M8 además expone escritorio remoto en 3389/3390.

Nunca corras `--tags security` desde una sesión remota sin haber hecho
`--check --diff` antes.

### sudo-rs (Ubuntu 25.10+)

Ubuntu trae ya **sudo-rs** como alternative por defecto en `/usr/bin/sudo`, y
el plugin `sudo` de Ansible no se entiende con él. Ansible pasa su prompt con
`-p` y espera verlo literal; sudo-rs lo envuelve en el suyo
(`[sudo: <prompt>] Password: `) y vuelve a preguntar, así que `-K` se queda
colgado y acaba en:

```
Timed out waiting for become success or become password prompt.
```

`host_vars/m8.yml` lo esquiva apuntando al sudo clásico, que sigue instalado
(paquete `sudo`) y emite el prompt desnudo:

```yaml
ansible_become_exe: /usr/bin/sudo.ws
```

Si una máquina nueva falla igual con `-K`, es esto. Comprueba con
`sudo --version`: si dice `sudo-rs`, añade la misma línea a su `host_vars/`.

### Docker

Si el host trae Docker como **snap** (lo detecta `main.yml` en `pre_tasks`), se
omiten repo, engine y grupo `docker`: dos motores compartiendo
`/var/run/docker.sock` es pedir problemas. Solo se asegura la red externa.

La red se crea por CLI, no con `community.docker`, porque el snap no expone el
SDK de Python que el módulo necesita.

Ubuntu 26.04 (`resolute`) todavía no tiene suite en `download.docker.com`;
`docker_apt_release_map` lo mapea a la última LTS publicada.

### GPG / firma de commits

Si la clave no está en el llavero y no existe `files/gpg_private.asc`, el role
avisa y sigue en vez de morir: el resto del playbook no depende de la firma.
Ver `files/README.md` para exportarla.
