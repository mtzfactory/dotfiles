# ansible/files/

Ficheros que Ansible copia al host. **Los secretos NO se versionan** (ver
`.gitignore` raíz).

## gpg_private.asc (no versionado)

Solo hace falta en una máquina **nueva**, donde la clave aún no está en el
llavero. Exportar desde una máquina que ya la tenga:

```bash
gpg --armor --export-secret-keys 06BCC481F5CE2B48 > ansible/files/gpg_private.asc
```

Luego:

```bash
ansible-playbook main.yml --tags git -K
```

Tras aprovisionar, bórralo: la clave queda importada en el host.

Si el fichero no existe y la clave tampoco está importada, el role **avisa y
sigue** en vez de fallar — el resto del playbook no depende de la firma de
commits.
