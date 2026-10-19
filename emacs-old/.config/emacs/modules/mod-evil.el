;;; mod-evil.el --- Vim keybindings (optional, off by default) -*- lexical-binding: t; -*-

;; Mutually exclusive with mod-nav.el - both remap hjkl-style navigation.

(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(provide 'mod-evil)
;;; mod-evil.el ends here
