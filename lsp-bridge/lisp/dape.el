;;; Debugging: Dape  -*- lexical-binding: t; -*-

(use-package dape
  :custom
  (dape-buffer-window-arrangement 'right)
  (dape-inlay-hints t)
  :config
  (when (fboundp 'dape-breakpoint-global-mode)
    (dape-breakpoint-global-mode 1))
  (require 'dape-scope-collapse nil t))

(use-package emacs
  :custom
  (window-sides-vertical t))

(defvar-keymap my/debug-map
  :doc "Debugging commands."
  "d" #'dape
  "b" #'dape-breakpoint-toggle
  "B" #'dape-breakpoint-remove-all
  "l" #'dape-breakpoint-log
  "x" #'dape-breakpoint-expression
  "c" #'dape-continue
  "n" #'dape-next
  "i" #'dape-step-in
  "o" #'dape-step-out
  "r" #'dape-restart
  "q" #'dape-quit
  "e" #'dape-evaluate-expression
  "w" #'dape-watch-dwim
  "R" #'dape-repl
  "I" #'dape-info)

(keymap-global-set "C-c d" my/debug-map)

(provide 'dape)
