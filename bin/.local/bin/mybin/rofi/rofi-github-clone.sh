#!/bin/sh
# rofi-github-clone — pick one of your GitHub repos in rofi, then pick (or type)
# a destination folder, then clone it there.
# Deps: rofi, git, jq, curl  (gh recommended for private repos)
#
# Usage:
#   rofi-github-clone.sh            # normal run, uses cache if fresh
#   rofi-github-clone.sh -r         # force a fresh fetch, ignore cache

GH_USER="iamziad"
CLONE_PROTO="ssh"   # "ssh" or "https"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-github-clone"
CACHE_FILE="$CACHE_DIR/repos.tsv"
CACHE_TTL=3600   # seconds. Use "↻ refresh list" in the menu, or -r, to bypass.

# Shortlist offered in the destination picker. You can still type any other
# path freely — this list is just convenience, not a restriction.
DEFAULT_DESTS="$HOME/Projects
$HOME/src
$HOME/Projects/personal
$HOME/Projects/learning
$HOME/tmp"

mkdir -p "$CACHE_DIR"

# Emits tab-separated "name<TAB>clone_url" lines, one per repo.
fetch_repos() {
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
        # gh, authenticated: includes private repos you own.
        gh repo list "$GH_USER" --limit 1000 --json name,sshUrl,url \
            | jq -r --arg proto "$CLONE_PROTO" \
                '.[] | "\(.name)\t\(if $proto == "ssh" then .sshUrl else .url end)"'
    else
        # Anonymous REST API: public repos only.
        page=1
        while :; do
            resp=$(curl -s "https://api.github.com/users/$GH_USER/repos?per_page=100&page=$page")
            # A non-array reply (rate limit, bad creds, network blip, etc.)
            # means we must stop here, not spin forever re-requesting.
            type=$(printf '%s' "$resp" | jq -r 'type' 2>/dev/null)
            if [ "$type" != "array" ]; then
                msg=$(printf '%s' "$resp" | jq -r '.message // "unexpected API response"' 2>/dev/null)
                notify-send "rofi-github-clone" "GitHub API error: $msg"
                break
            fi
            count=$(printf '%s' "$resp" | jq 'length')
            [ "$count" -eq 0 ] && break
            printf '%s' "$resp" | jq -r --arg proto "$CLONE_PROTO" \
                '.[] | "\(.name)\t\(if $proto == "ssh" then .ssh_url else .clone_url end)"'
            page=$((page + 1))
        done
    fi
}

cache_is_fresh() {
    [ -f "$CACHE_FILE" ] || return 1
    mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null) || return 1
    age=$(( $(date +%s) - mtime ))
    [ "$age" -lt "$CACHE_TTL" ]
}

if [ "$1" = "-r" ] || [ "$1" = "--refresh" ] || ! cache_is_fresh; then
    fetch_repos > "$CACHE_FILE"
fi

mapping=$(cat "$CACHE_FILE")

if [ -z "$mapping" ]; then
    notify-send "rofi-github-clone" "no repos found / API error"
    exit 1
fi

repo=$(
    { echo "↻ refresh list"; printf '%s\n' "$mapping" | cut -f1 | sort; } \
        | rofi -dmenu -i -p "clone repo"
)
[ -z "$repo" ] && exit 0

if [ "$repo" = "↻ refresh list" ]; then
    fetch_repos > "$CACHE_FILE"
    exec "$0"
fi

url=$(printf '%s\n' "$mapping" | awk -F'\t' -v name="$repo" '$1 == name { print $2; exit }')

# Pick a destination folder. Type any path you like — these are just defaults.
dest=$(printf '%s\n' "$DEFAULT_DESTS" | rofi -dmenu -i -p "clone into" -mesg "repo: $repo")
[ -z "$dest" ] && exit 0

case "$dest" in
    "~"*)  dest="$HOME${dest#\~}" ;;
    /*)    ;;
    *)     dest="$HOME/$dest" ;;
esac

mkdir -p "$dest" || { notify-send "rofi-github-clone" "could not create $dest"; exit 1; }

target="$dest/$repo"

if [ -d "$target" ]; then
    notify-send "rofi-github-clone" "$repo already exists at $target"
    exit 0
fi

log=$(mktemp /tmp/rofi-github-clone.XXXXXX.log)

# --progress forces git to emit \r-updated percentages even though stdout
# isn't a real terminal here.
git clone --progress "$url" "$target" >"$log" 2>&1 &
pid=$!

# -p prints a notification ID we can keep replacing in place (-r) instead of
# spawning a new popup every tick. Older notify-send builds without -p just
# leave $nid empty and we silently skip the live updates below.
nid=$(notify-send -p "cloning $repo" "starting..." 2>/dev/null)

while kill -0 "$pid" 2>/dev/null; do
    sleep 0.5
    [ -z "$nid" ] && continue
    line=$(tr '\r' '\n' <"$log" | tail -n1 | sed 's/[[:space:]]*$//')
    [ -z "$line" ] && continue
    pct=$(printf '%s' "$line" | grep -oE '[0-9]+%' | head -n1 | tr -d '%')
    if [ -n "$pct" ]; then
        notify-send -r "$nid" -h "int:value:$pct" "cloning $repo" "$line"
    else
        notify-send -r "$nid" "cloning $repo" "$line"
    fi
done

wait "$pid"
status=$?
rm -f "$log"

if [ "$status" -eq 0 ]; then
    msg="cloned $repo -> $target"
else
    msg="failed to clone $repo (exit $status)"
fi

if [ -n "$nid" ]; then
    notify-send -r "$nid" "rofi-github-clone" "$msg"
else
    notify-send "rofi-github-clone" "$msg"
fi
