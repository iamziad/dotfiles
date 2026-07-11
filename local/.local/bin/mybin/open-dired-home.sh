#!/usr/bin/env bash

DIR="$HOME"

if emacsclient -e "(emacs-pid)" >/dev/null 2>&1; then

    HAS_FRAME=$(emacsclient -e "(if (filtered-frame-list (lambda (f) (display-graphic-p f))) t nil)" 2>/dev/null | tr -d '"')

    if [[ "$HAS_FRAME" == "t" ]]; then
        emacsclient -n -e "(progn
            (select-frame-set-input-focus (car (filtered-frame-list (lambda (f) (display-graphic-p f)))))
            (dired \"$DIR\")
            (delete-other-windows))"
    else
        emacsclient -n -c -F "'(fullscreen . maximized)" -a "" -e "(dired \"$DIR\")"
    fi
else
    emacs --maximized "$DIR" &
fi
