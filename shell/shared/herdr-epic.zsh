#!/usr/bin/env zsh

##
# Herdr epic manager tab
#
# Depends on sanitize() and _wt_repo_folder(), defined in
# shell/shared/wt-session.zsh. Not redefined here: customize.zsh sources
# wt-session.zsh before this file, and in any case both are sourced once at
# shell startup, long before epic() is ever invoked interactively, so the
# functions are already in scope by the time this runs. If wt-session.zsh is
# ever removed or renamed, epic() breaks — keep this comment in sync with
# that file's existence.

# Adds (or reuses) an "epic-<KEY>" manager tab in the herdr workspace ALREADY
# open for the current repo checkout — this does NOT create a new workspace.
# The repo must already be open in herdr (e.g. via `wto`/`wts`, or just the
# primary checkout opened normally); otherwise this errors out instead of
# creating one, since there'd be no "already open" workspace to decide what
# that even means.
#
# Usage: epic <EPIC-KEY> [jira-url]
epic() {
  local epic_key="$1"
  local jira_url="$2"
  if [[ -z "$epic_key" ]]; then
    echo "epic: usage: epic <EPIC-KEY> [jira-url]" >&2
    return 1
  fi

  if ! herdr workspace list >/dev/null 2>&1; then
    echo "epic: herdr server not running" >&2
    return 1
  fi

  local checkout_path
  checkout_path=$(git rev-parse --show-toplevel 2>/dev/null) \
    || { echo "epic: not inside a git repo" >&2; return 1; }

  # Match against .worktree.checkout_path, which herdr reports for every
  # workspace backed by a checkout — including the primary (non-linked) one,
  # not just worktree-linked workspaces. Works the same whether this is
  # invoked from inside herdr (any pane of that workspace) or from a plain
  # terminal outside it.
  local workspace_id
  workspace_id=$(herdr workspace list 2>/dev/null \
    | jq -r --arg p "$checkout_path" \
        '.result.workspaces[] | select(.worktree.checkout_path == $p) | .workspace_id' \
    | head -1)
  if [[ -z "$workspace_id" || "$workspace_id" == "null" ]]; then
    echo "epic: no herdr workspace open for $checkout_path — open it first" >&2
    return 1
  fi

  # herdr agent names must be all-lowercase (letters/digits/-/_); ticket and
  # epic keys (RVS, TOC-1234...) are not, so lowercase just the agent name —
  # tab label, session-id, branch, and brief keep the original casing.
  local agent_name="epic-$(sanitize "${(L)epic_key}")-manager"

  local tab_label="epic-$(sanitize "$epic_key")"
  local tab_line tab_id agent_status
  tab_line=$(herdr tab list --workspace "$workspace_id" \
    | jq -r --arg l "$tab_label" '.result.tabs[] | select(.label == $l) | "\(.tab_id)\t\(.agent_status)"' | head -1)
  tab_id="${tab_line%%$'\t'*}"
  agent_status="${tab_line##*$'\t'}"
  [[ "$tab_line" == *$'\t'* ]] || tab_id=""

  local need_agent=false
  if [[ -z "$tab_id" ]]; then
    local result
    result=$(herdr tab create --workspace "$workspace_id" --label "$tab_label" --cwd "$checkout_path" --no-focus)
    tab_id=$(echo "$result" | jq -r '.result.tab.tab_id')
    if [[ -z "$tab_id" || "$tab_id" == "null" ]]; then
      echo "epic: failed to create tab" >&2
      echo "$result" >&2
      return 1
    fi
    need_agent=true
  elif [[ -z "$agent_status" || "$agent_status" == "unknown" ]]; then
    # Tab exists but has no agent attached yet — e.g. a previous `epic` run
    # created the tab and then failed before `agent start` (bad agent name,
    # herdr restart, etc.). Retry starting the agent in the existing pane
    # instead of only focusing an empty shell.
    echo "epic: tab '$tab_label' exists but has no agent, (re)starting it"
    need_agent=true
  else
    echo "epic: tab '$tab_label' already has an agent ($agent_status), focusing it"
  fi

  if $need_agent; then
    local pane_id
    pane_id=$(herdr pane list --workspace "$workspace_id" \
      | jq -r --arg t "$tab_id" '.result.panes[] | select(.tab_id == $t) | .pane_id')

    # Brief persists outside the session (and outside the repo, for now) so a
    # compacted/fresh session can still recover the epic's context instead of
    # relying only on conversation history.
    local epic_dir="$HOME/.pi/agent/epics/$(sanitize "$(_wt_repo_folder)")"
    mkdir -p "$epic_dir"
    local epic_brief="$epic_dir/${epic_key}.md"
    local is_first_boot=false
    if [[ ! -f "$epic_brief" ]]; then
      is_first_boot=true
      cat > "$epic_brief" <<EOF
# Epic ${epic_key}

Jira: ${jira_url:-https://trainline.atlassian.net/browse/${epic_key}}

(pending: filled in automatically on first manager boot)
EOF
    fi

    herdr agent start "$agent_name" --kind pi --pane "$pane_id" \
      -- --session-id "epic-${epic_key}" \
         --append-system-prompt "$epic_brief" \
         --skill "$HOME/.agents/skills/start-ticket-worker"

    if $is_first_boot; then
      # Only send the bootstrap prompt on a truly fresh epic (brief just
      # created). A resumed agent (tab/pane was closed but --session-id
      # already has history) just needs waking up — it already has its own
      # conversation; re-sending this would make it redo the Jira research.
      herdr agent prompt "$agent_name" \
        "Eres el manager de la épica ${epic_key}. Usa Atlassian MCP para traer la épica y sus tickets, resume su alcance y decisiones clave, y guarda ese resumen en ${epic_brief} (sobrescribe el placeholder). Si tienes context-mode, indéxalo con source \"epic-${epic_key}\". Luego espera: te iré pasando enlaces de tickets para que uses el skill start-ticket-worker." \
        --wait --until working --timeout 60000
    else
      herdr agent wait "$agent_name" --until idle --until working --until blocked --timeout 30000 >/dev/null 2>&1
    fi
  fi

  herdr tab focus "$tab_id"
  [[ -z "$HERDR_ENV" ]] && herdr
}
