#!/usr/bin/env bash
#
# migrate-structure.sh
# 1) Renombra os/ -> shell/ y symlinks/ -> config/ preservando historial.
# 2) Aplana config/config/ -> config/ (las configs de apps suben un nivel).
# 3) Corrige las referencias de ruta internas en scripts y README.
#
# Ejecutar UNA vez, desde la raíz del repo dotfiles, con el árbol limpio.
# Funciona en macOS y Linux (usa `perl -i`, portable).

set -euo pipefail

# ── Pre-flight ──────────────────────────────────────────────────────────────
[[ -d os && -d symlinks ]] || {
  echo "✗ Ejecuta desde la raíz del repo dotfiles (se esperan os/ y symlinks/)."
  exit 1
}
[[ -z "$(git status --porcelain)" ]] || {
  echo "✗ El árbol de trabajo no está limpio. Commitea o stashea antes de migrar."
  exit 1
}

# Colisiones del aplanado: nada en symlinks/config/ puede llamarse como
# algo que ya exista en symlinks/ (git, ssh…).
for entry in symlinks/config/*; do
  name="$(basename "$entry")"
  [[ -e "symlinks/$name" ]] && {
    echo "✗ Colisión: symlinks/config/$name ya existe como symlinks/$name."
    echo "  Resuelve el conflicto antes de aplanar."
    exit 1
  }
done

# ── 1. Renombrados (preservan historial de Git) ─────────────────────────────
git mv os shell
git mv symlinks config

# ── 2. Aplanar config/config/ → config/ ─────────────────────────────────────
for entry in config/config/*; do
  git mv "$entry" config/
done
rmdir config/config 2>/dev/null || true

# ── 3. Corregir referencias internas ────────────────────────────────────────
#   $DOTFILES/os/...      → $DOTFILES/shell/...
perl -i -pe 's{\$DOTFILES/os/}{\$DOTFILES/shell/}g' \
  shell/customize.zsh \
  shell/install-apps.zsh \
  README.md

#   $DOTFILES/symlinks... → $DOTFILES/config...
perl -i -pe 's{\$DOTFILES/symlinks}{\$DOTFILES/config}g' \
  shell/create-symlinks.zsh \
  shell/linux/customize-linux.zsh \
  shell/darwin/customize-darwin.zsh

#   Aplanado: las app configs ya no viven en un subdirectorio config/
perl -i -pe 's{\$DOTFILES_SYMLINKS/config}{\$DOTFILES_SYMLINKS}g' \
  shell/create-symlinks.zsh

# ── 4. Sanity check ─────────────────────────────────────────────────────────
fail=0
if grep -rnE '\$DOTFILES/(os|symlinks)/' shell README.md 2>/dev/null; then
  echo "✗ Quedan referencias antiguas os/symlinks (arriba)."
  fail=1
fi
if grep -rn '\$DOTFILES_SYMLINKS/config' shell 2>/dev/null; then
  echo "✗ Quedan referencias al subdirectorio config/ aplanado (arriba)."
  fail=1
fi
[[ -d config/config ]] && { echo "✗ config/config/ sigue existiendo."; fail=1; }
[[ $fail -eq 1 ]] && exit 1

git add -A
echo
echo "✓ Estructura migrada y aplanada. Revisa con:"
echo "    git diff --staged"
echo "  y commitea cuando estés conforme."
echo
echo "⚠️  RECORDATORIOS — pasos manuales fuera del repo, en CADA Mac:"
echo "  1. En ~/.zshrc, cambia la línea de arranque:"
echo "       \$DOTFILES/os/customize.zsh  →  \$DOTFILES/shell/customize.zsh"
echo "  2. Elimina los symlinks colgantes (apuntan a symlinks/…, ya no existe):"
echo "       rm ~/.config/lazygit ~/.config/nvim ~/.config/worktrunk ~/.config/pip"
echo "       rm ~/.gitconfig ~/.gitconfig-* ~/.gitignore-global ~/.ssh/config"
echo "     y abre una shell nueva: create-symlinks.zsh los recrea con las rutas nuevas."
echo "     (Verifica antes con: ls -la ~/.config ~/.gitconfig* ~/.ssh/config)"
echo "  (En el M8 no hay que hacer nada: Ansible aprovisiona con las rutas nuevas.)"
