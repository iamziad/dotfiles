;; -*- lexical-binding: t; -*-

(use-package lsp-bridge
  :vc (:url "https://github.com/manateelazycat/lsp-bridge.git"
       :rev :newest)
  :hook ((prog-mode . lsp-bridge-mode))
  :diminish lsp-bridge-mode
  :bind (:map lsp-bridge-mode-map
         ("M-." . lsp-bridge-find-def)
         ("M-," . lsp-bridge-find-def-return)
         ("M-?" . lsp-bridge-find-references))
  :config
  (require 'lsp-bridge-jdtls)
  :init
  (setq lsp-bridge-python-command
        (expand-file-name
         "~/.local/share/lsp-bridge-venv/bin/python")))

(defvar-keymap my/lsp-bridge-map
  :doc "LSP commands (bound under C-c l)."
  "a" #'lsp-bridge-code-action
  "d" #'lsp-bridge-popup-documentation
  "f" #'lsp-bridge-code-format
  "i" #'lsp-bridge-find-impl
  "l" #'lsp-bridge-diagnostic-list
  "n" #'lsp-bridge-diagnostic-jump-next
  "p" #'lsp-bridge-diagnostic-jump-prev
  "r" #'lsp-bridge-rename
  "t" #'lsp-bridge-find-type-def
  "R" #'lsp-bridge-restart-process)

(keymap-global-set "C-c l" my/lsp-bridge-map)

(provide 'init-lsp-bridge)
