#!/usr/bin/env bash
# Claude Code status line — two rows.
# Row 1 (mauve): session name | model | directory | git branch + status
# Row 2 (black): elapsed | session cost | context bar | 5h bar | 7d bar | credit
#
# Most data comes from the status line's own input JSON (Claude Code >= ~2.1.x):
# context_window.used_percentage and rate_limits.* are provided natively.
#
# The credit segment is the exception: usage-credit balance and spend are not in
# the input JSON, so they are fetched from the Claude API with the OAuth token
# Claude Code already stores. That fetch never happens inline — the render only
# ever reads a cache file, and a stale cache triggers a detached background
# refresh, so the status line cannot block on the network.

# --- Credit balance/spend cache (must precede the blocking `cat` below) ---
CREDIT_CACHE="$HOME/.claude/statusline-credit-cache.json"
CREDIT_LOCK="$HOME/.claude/statusline-credit-cache.lock"
CREDIT_TTL=120   # serve the cache for this long
CREDIT_RETRY=60  # floor between refresh attempts, so failures don't hammer

file_age() {
  # seconds since mtime; large number when the file is absent
  local f=$1 mtime
  mtime=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null) || { printf '999999'; return; }
  [ -z "$mtime" ] && { printf '999999'; return; }
  printf '%s' "$(( $(date +%s) - mtime ))"
}

refresh_credit_cache() {
  command -v jq >/dev/null 2>&1 || return
  command -v curl >/dev/null 2>&1 || return

  local creds token org usage prepaid tmp
  creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  [ -z "$creds" ] && [ -f "$HOME/.claude/.credentials.json" ] && creds=$(cat "$HOME/.claude/.credentials.json")
  token=$(printf '%s' "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  [ -z "$token" ] && return

  org=$(jq -r '.oauthAccount.organizationUuid // empty' "$HOME/.claude.json" 2>/dev/null)

  usage=$(curl -sS --max-time 10 \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "Content-Type: application/json" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
  printf '%s' "$usage" | jq -e . >/dev/null 2>&1 || return

  prepaid='null'
  if [ -n "$org" ]; then
    prepaid=$(curl -sS --max-time 10 \
      -H "Authorization: Bearer $token" \
      -H "anthropic-beta: oauth-2025-04-20" \
      -H "Content-Type: application/json" \
      "https://api.anthropic.com/api/oauth/organizations/$org/prepaid/credits" 2>/dev/null)
    printf '%s' "$prepaid" | jq -e . >/dev/null 2>&1 || prepaid='null'
  fi

  # Normalise to a tiny, stable shape so the render path stays cheap.
  # balance -> prepaid credits remaining; spent -> usage credits consumed.
  # `pct` prefers the API's own utilization (set when a monthly spend limit
  # exists) and otherwise derives spend as a share of the whole pot.
  tmp="${CREDIT_CACHE}.$$"
  printf '%s' "$usage" | jq -c \
    --argjson prepaid "${prepaid:-null}" '
    (.extra_usage // {}) as $x
    | ($x.decimal_places // 2) as $dp
    | ($prepaid.amount // null) as $bal
    | ($x.used_credits // null) as $spent
    | {
        enabled:  ($x.is_enabled // false),
        currency: ($prepaid.currency // $x.currency // "USD"),
        dp:       $dp,
        balance:  $bal,
        spent:    $spent,
        pct: (
          if ($x.utilization != null) then $x.utilization
          elif ($bal != null and $spent != null and ($bal + $spent) > 0) then ($spent / ($bal + $spent) * 100)
          else null end
        )
      }' > "$tmp" 2>/dev/null && mv -f "$tmp" "$CREDIT_CACHE" || rm -f "$tmp"
}

# Detached refresh worker: re-entry point for the background spawn below.
if [ "$1" = "--refresh-credit" ]; then
  refresh_credit_cache
  exit 0
fi

input=$(cat)

session_id=$(echo "$input" | jq -r '.session_id // empty')
session_name=$(echo "$input" | jq -r '.session_name // empty')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd=$PWD
dir_name=$(basename "$cwd")
repo_name=$(echo "$input" | jq -r '.workspace.repo.name // empty')

duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# --- Are credits actually being drawn down? ---
# Usage credits only start paying for requests once a subscription window is
# spent, so the credit segment stays hidden until then. With no rate_limits at
# all there is no subscription quota to exhaust and credits pay from the start.
credits_active=false
if [ -z "$five_pct" ] && [ -z "$week_pct" ]; then
  credits_active=true
else
  if [ -n "$five_pct" ] && [ "$(printf '%.0f' "$five_pct")" -ge 100 ]; then
    credits_active=true
  fi
  if [ -n "$week_pct" ] && [ "$(printf '%.0f' "$week_pct")" -ge 100 ]; then
    credits_active=true
  fi
fi

# Only reach for the network when the numbers would actually be shown. Never
# wait for the result: a stale cache renders as-is while a detached worker
# refreshes it, and the lock's mtime rate-limits attempts, failures included.
if [ "$credits_active" = true ] &&
   [ "$(file_age "$CREDIT_CACHE")" -gt "$CREDIT_TTL" ] &&
   [ "$(file_age "$CREDIT_LOCK")" -gt "$CREDIT_RETRY" ]; then
  touch "$CREDIT_LOCK" 2>/dev/null
  (bash "$0" --refresh-credit >/dev/null 2>&1 &) </dev/null
fi

# --- Nerd Font icons (verified present in MesloLGS NF) ---
NF_GIT=$'\xee\x82\xa0'     # U+E0A0 powerline git branch
NF_FOLDER=$'\xef\x81\xbb'  # U+F07B folder
NF_CLOCK=$'\xef\x80\x97'   # U+F017 clock
ICON_MODEL='✦'             # U+2726 — Nerd Fonts v3 model glyphs are absent in MesloLGS NF

# Diagonal corner cuts for row 1: the glyph is drawn in the row's background
# color on the terminal's own background, tapering the block's ends. Row 2 has
# no background of its own, so it needs no cuts.
#
# Note: filling to the terminal edge is not possible here. The width cannot be
# measured (tput cols reports terminfo's 80 default, /dev/tty is unavailable,
# COLUMNS is 0), and erase-to-end-of-line is stripped by the status line
# renderer, so the block is sized to its content instead.
NF_CORNER_TL=$'\xee\x82\xba'  # U+E0BA lower-right fill  -> top-left cut
NF_CORNER_TR=$'\xee\x82\xb8'  # U+E0B8 lower-left fill   -> top-right cut

# --- Git branch + granular status ---
git_branch=""
git_status=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -z "$git_branch" ]; then
    git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  modified=$(git -C "$cwd" --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
  [ "$staged" -gt 0 ] && git_status="+${staged}"
  [ "$modified" -gt 0 ] && git_status="${git_status:+$git_status }!${modified}"
  [ "$untracked" -gt 0 ] && git_status="${git_status:+$git_status }?${untracked}"
fi

# --- Formatting helpers ---
fmt_duration() {
  local ms=$1
  [ -z "$ms" ] && return
  local total_s=$((ms / 1000))
  local h=$((total_s / 3600))
  local m=$(((total_s % 3600) / 60))
  local s=$((total_s % 60))
  if [ "$h" -gt 0 ]; then
    printf '%dh%02dm' "$h" "$m"
  elif [ "$m" -gt 0 ]; then
    printf '%dm%02ds' "$m" "$s"
  else
    printf '%ds' "$s"
  fi
}

fmt_size() {
  local size=$1
  [ -z "$size" ] && return
  if [ "$size" -ge 1000000 ]; then
    printf '%sM' "$((size / 1000000))"
  else
    printf '%sk' "$((size / 1000))"
  fi
}

fmt_money() {
  # fmt_money <minor_units> <currency> <decimal_places> -> "€49.39"
  local minor=$1 cur=$2 dp=${3:-2} sym
  [ -z "$minor" ] && return
  case $cur in
    EUR) sym='€' ;;
    USD) sym='$' ;;
    GBP) sym='£' ;;
    JPY) sym='¥' ;;
    *)   sym="${cur} " ;;
  esac
  awk -v m="$minor" -v dp="$dp" -v s="$sym" \
    'BEGIN { printf "%s%.*f", s, dp, m / (10 ^ dp) }'
}

fmt_reset() {
  # epoch seconds -> "now" / "Xm" / "XhYm" / "XdYh"
  local reset_at=$1
  [ -z "$reset_at" ] && return
  local now diff
  now=$(date +%s)
  diff=$((reset_at - now))
  [ "$diff" -le 60 ] && { printf 'now'; return; }
  local d=$((diff / 86400))
  local h=$(((diff % 86400) / 3600))
  local m=$(((diff % 3600) / 60))
  if [ "$d" -gt 0 ]; then
    printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then
    printf '%dh%dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

# --- Colors (truecolor) ---
RESET=$'\033[0m'

# Row 1 hue is hashed from the session id, so concurrent sessions look distinct.
# Pin a project to a fixed index (0-11) in statusline-color-overrides.json:
#   { "/path/to/project": 4 }
color_idx=""
overrides="$HOME/.claude/statusline-color-overrides.json"
if [ -f "$overrides" ]; then
  project_root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")
  color_idx=$(jq -r --arg p "$project_root" '.[$p] // empty' "$overrides" 2>/dev/null)
fi
if [ -z "$color_idx" ]; then
  phash=$(printf '%s' "${session_id:-$cwd}" | cksum | cut -d' ' -f1)
  color_idx=$((phash % 12))
fi

case $color_idx in
  0)  c_r=105; c_g=145; c_b=225 ;;  # blue
  1)  c_r=130; c_g=190; c_b=130 ;;  # green
  2)  c_r=190; c_g=130; c_b=175 ;;  # pink
  3)  c_r=200; c_g=170; c_b=100 ;;  # amber
  4)  c_r=100; c_g=185; c_b=185 ;;  # teal
  5)  c_r=175; c_g=130; c_b=190 ;;  # purple
  6)  c_r=110; c_g=170; c_b=210 ;;  # sky
  7)  c_r=180; c_g=190; c_b=110 ;;  # olive
  8)  c_r=200; c_g=140; c_b=130 ;;  # coral
  9)  c_r=130; c_g=170; c_b=180 ;;  # steel
  10) c_r=190; c_g=175; c_b=120 ;;  # khaki
  11) c_r=160; c_g=130; c_b=190 ;;  # violet
  *)  c_r=205; c_g=150; c_b=205 ;;  # fallback: mauve
esac

# Text and dividers derive from the same hue so the block coheres.
BG1=$'\033[48;2;'"${c_r};${c_g};${c_b}"'m'
FG1=$'\033[1;38;2;'"$((c_r * 15 / 100));$((c_g * 15 / 100));$((c_b * 15 / 100))"'m'
DIV1=$'\033[22;38;2;'"$((c_r * 40 / 100));$((c_g * 40 / 100));$((c_b * 40 / 100))"'m'
CORNER1=$'\033[38;2;'"${c_r};${c_g};${c_b}"'m'

# Row 2: transparent — no background set, so the terminal's own shows through
FG2=$'\033[22;38;2;222;222;228m'
DIV2=$'\033[38;2;80;80;88m'
EMPTY=$'\033[38;2;70;70;78m'
MUTED=$'\033[38;2;140;140;150m'

# Usage scale: fresh -> watch it -> act
SAGE=$'\033[38;2;150;210;150m'
GOLD=$'\033[38;2;215;195;125m'
CORAL=$'\033[38;2;225;150;150m'

base1="${BG1}${FG1}"
base2="${FG2}"
SEP1=" ${DIV1}│${FG1} "
SEP2=" ${DIV2}│${FG2} "

pct_color() {
  local p=$1
  if [ "$p" -gt 80 ]; then
    printf '%s' "$CORAL"
  elif [ "$p" -gt 50 ]; then
    printf '%s' "$GOLD"
  else
    printf '%s' "$SAGE"
  fi
}

bar() {
  # bar <pct> <width> <fill_color> -> colored filled blocks + dim empty blocks
  local pct=$1 width=$2 fill=$3
  [ -z "$pct" ] && return
  local filled=$((pct * width / 100))
  # always show at least one block for any non-zero usage
  [ "$pct" -gt 0 ] && [ "$filled" -eq 0 ] && filled=1
  [ "$filled" -gt "$width" ] && filled=$width
  local empty=$((width - filled))
  local out="${fill}" i
  for ((i = 0; i < filled; i++)); do out="${out}▰"; done
  out="${out}${EMPTY}"
  for ((i = 0; i < empty; i++)); do out="${out}▱"; done
  printf '%s' "$out"
}

# --- Row 1 ---
row1_parts=()

if [ -n "$session_name" ]; then
  if [ -n "$repo_name" ]; then
    row1_parts+=("${repo_name}: ${session_name}")
  else
    row1_parts+=("${session_name}")
  fi
fi

row1_parts+=("${ICON_MODEL} ${model}")
row1_parts+=("${NF_FOLDER} ${dir_name}")

if [ -n "$git_branch" ]; then
  if [ -n "$git_status" ]; then
    row1_parts+=("${NF_GIT} ${git_branch} ${git_status}")
  else
    row1_parts+=("${NF_GIT} ${git_branch}")
  fi
fi

row1=""
for part in "${row1_parts[@]}"; do
  if [ -z "$row1" ]; then
    row1="$part"
  else
    row1="${row1}${SEP1}${part}"
  fi
done

# --- Row 2 ---
row2_parts=()

if [ -n "$duration_ms" ]; then
  hours=$((duration_ms / 3600000))
  if [ "$hours" -gt 2 ]; then
    time_clr=$CORAL
  elif [ "$hours" -gt 0 ]; then
    time_clr=$GOLD
  else
    time_clr=$SAGE
  fi
  row2_parts+=("${NF_CLOCK} ${time_clr}$(fmt_duration "$duration_ms")${FG2}")
fi

# Session cost, always in USD regardless of the billing currency below.
# Resets to $0 on /clear, since that starts a new session.
if [ -n "$cost_usd" ]; then
  cost_clr=$(awk -v c="$cost_usd" -v s="$SAGE" -v g="$GOLD" -v r="$CORAL" \
    'BEGIN { print (c >= 5 ? r : (c >= 1 ? g : s)) }')
  row2_parts+=("${cost_clr}$(printf '$%.2f' "$cost_usd")${FG2}")
fi

if [ -n "$ctx_pct" ]; then
  ctx_n=$(printf '%.0f' "$ctx_pct")
  ctx_clr=$(pct_color "$ctx_n")
  row2_parts+=("$(bar "$ctx_n" 8 "$ctx_clr")  ${ctx_clr}${ctx_n}%${FG2} of $(fmt_size "$ctx_size")")
fi

if [ -n "$five_pct" ]; then
  five_n=$(printf '%.0f' "$five_pct")
  five_clr=$(pct_color "$five_n")
  row2_parts+=("5h $(bar "$five_n" 5 "$five_clr")  ${five_clr}${five_n}%${FG2} ${MUTED}$(fmt_reset "$five_reset")${FG2}")
fi

if [ -n "$week_pct" ]; then
  week_n=$(printf '%.0f' "$week_pct")
  week_clr=$(pct_color "$week_n")
  row2_parts+=("7d $(bar "$week_n" 5 "$week_clr")  ${week_clr}${week_n}%${FG2} ${MUTED}$(fmt_reset "$week_reset")${FG2}")
fi

# Credit balance + spend, shown only once credits are the thing paying for
# requests: a subscription window exhausted and usage credits switched on.
if [ "$credits_active" = true ] && [ -f "$CREDIT_CACHE" ]; then
  cr_enabled=$(jq -r '.enabled // false' "$CREDIT_CACHE" 2>/dev/null)
  cr_balance=$(jq -r '.balance // empty' "$CREDIT_CACHE" 2>/dev/null)
  cr_spent=$(jq -r '.spent // empty' "$CREDIT_CACHE" 2>/dev/null)
  cr_cur=$(jq -r '.currency // "USD"' "$CREDIT_CACHE" 2>/dev/null)
  cr_dp=$(jq -r '.dp // 2' "$CREDIT_CACHE" 2>/dev/null)
  cr_pct=$(jq -r '.pct // empty' "$CREDIT_CACHE" 2>/dev/null)

  if [ "$cr_enabled" = "true" ] && { [ -n "$cr_balance" ] || [ -n "$cr_spent" ]; }; then
    cr_seg="credit"
    if [ -n "$cr_pct" ]; then
      cr_n=$(printf '%.0f' "$cr_pct")
      cr_clr=$(pct_color "$cr_n")
      cr_seg="${cr_seg} $(bar "$cr_n" 5 "$cr_clr")"
    else
      cr_clr=$SAGE
    fi
    [ -n "$cr_balance" ] && cr_seg="${cr_seg}  ${cr_clr}$(fmt_money "$cr_balance" "$cr_cur" "$cr_dp")${FG2} left"
    [ -n "$cr_spent" ] && cr_seg="${cr_seg} ${MUTED}$(fmt_money "$cr_spent" "$cr_cur" "$cr_dp") spent${FG2}"
    row2_parts+=("$cr_seg")
  fi
fi

row2=""
for part in "${row2_parts[@]}"; do
  if [ -z "$row2" ]; then
    row2="$part"
  else
    row2="${row2}${SEP2}${part}"
  fi
done

# --- Pad both rows to equal visible width so the background blocks align ---
visible_width() {
  printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g' | LC_ALL=en_US.UTF-8 wc -m | tr -d ' '
}

w1=$(visible_width "$row1")
w2=$(visible_width "$row2")
target=$w1
[ "$w2" -gt "$target" ] && target=$w2

pad() {
  local n=$1
  [ "$n" -le 0 ] && return
  printf '%*s' "$n" ''
}

row1="${row1}$(pad $((target - w1)))"
row2="${row2}$(pad $((target - w2)))"

printf "%s\n%s" \
  "${RESET}${CORNER1}${NF_CORNER_TL}${base1} ${row1} ${RESET}${CORNER1}${NF_CORNER_TR}${RESET}" \
  "${RESET}${base2}  ${row2}${RESET}"
