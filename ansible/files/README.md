# ansible/files/

Ficheros que Ansible copia al servidor. **Los secretos NO se versionan** (ver `.gitignore` raíz).

## gpg_private.asc (no versionado)

Exportar desde el Mac antes de ejecutar el playbook:

```bash
gpg --armor --export-secret-keys 06BCC481F5CE2B48 > ansible/files/gpg_private.asc
```

Tras aprovisionar, puede borrarse localmente; la clave queda importada en el M8.
