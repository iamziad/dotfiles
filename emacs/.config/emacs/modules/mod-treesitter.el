;;; mod-treesitter.el --- Tree-sitter grammars & major modes -*- lexical-binding: t; -*-

(setq warning-suppress-types
      '((treesit-font-lock-rules-mismatch)))

(use-package treesit-auto
  :custom (treesit-auto-install 'prompt)
  :config
  (setq treesit-font-lock-level 4)
  (global-treesit-auto-mode))

(use-package combobulate
  :hook ((prog-mode . combobulate-mode))
  :bind
  (:map combobulate-mode-map
        ;; Navigation
        ("M-n"   . combobulate-navigate-next)
        ("M-p"   . combobulate-navigate-previous)
        ("M-N"   . combobulate-drag-down)
        ("M-P"   . combobulate-drag-up)

        ;; Dragging / Movement
        ("M-[" . combobulate-drag-down)
        ("M-]"   . combobulate-drag-up)

        ;; Selection & Editing
        ("C-c o s"  . combobulate-mark-node)
        ("C-c o k"  . combobulate-kill-node)
        ("C-c o w"  . combobulate-envelope-mw)
        ("C-c o S"  . combobulate-splice)

        ;; Refactoring / Transpose
        ("C-c o t"  . combobulate-transpose-sexps)
        ("C-c o a"  . combobulate-ui-visual-edit)))

(provide 'mod-treesitter)
;;; mod-treesitter.el ends here
