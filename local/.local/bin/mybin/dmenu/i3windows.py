#!/usr/bin/env python3
"""
i3-dmenu-windows.py
Lists all open i3 windows in a clean, organized dmenu menu and
jumps to whichever one you pick.
Format shown per line:
  [workspace] app_name    window title   (app_name column is fixed-width)
Requires: i3ipc (pip install i3ipc / python-i3ipc from your distro repo)
"""
import subprocess
import sys
from i3ipc import Connection

DMENU_CMD = ["dmenu", "-i", "-p", "Window:", "-l", "20", "-fn", "monospace:size=11"]


def get_windows(i3):
    """Return list of (con_id, display_string), aligned into fixed-width columns."""
    raw = []  # (con_id, ws_name, app_class, title)
    tree = i3.get_tree()

    for ws in tree.workspaces():
        ws_name = ws.name
        for con in ws.leaves():
            if not con.window:
                continue
            app_class = con.window_class or con.app_id or "?"
            title = con.name or "(untitled)"

            # trim long titles so the menu stays clean
            if len(title) > 70:
                title = title[:67] + "..."

            raw.append((con.id, ws_name, app_class, title))

    if not raw:
        return []

    # fixed widths so columns line up across all rows
    ws_width = max(len(f"[{ws}]") for _, ws, _, _ in raw)
    class_width = max(len(cls) for _, _, cls, _ in raw)

    entries = []
    for con_id, ws_name, app_class, title in raw:
        ws_col = f"[{ws_name}]".ljust(ws_width)
        class_col = app_class.ljust(class_width)
        display = f"{ws_col}  {class_col}  {title}"
        entries.append((con_id, display))

    # sort by workspace name/number, keep stable order within a workspace
    entries.sort(key=lambda e: e[1])
    return entries


def run_dmenu(entries):
    menu_input = "\n".join(display for _, display in entries)
    try:
        result = subprocess.run(
            DMENU_CMD,
            input=menu_input,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        print("dmenu not found in PATH.", file=sys.stderr)
        sys.exit(1)
    return result.stdout.strip()


def main():
    i3 = Connection()
    entries = get_windows(i3)
    if not entries:
        subprocess.run(["notify-send", "i3-dmenu-windows", "No opened windows"])
        sys.exit(0)
    choice = run_dmenu(entries)
    if not choice:
        sys.exit(0)  # user cancelled (Esc)
    for con_id, display in entries:
        if display == choice:
            i3.command(f'[con_id="{con_id}"] focus')
            break
    else:
        # in case dmenu returned something typed manually, not in the list
        sys.exit(0)


if __name__ == "__main__":
    main()
