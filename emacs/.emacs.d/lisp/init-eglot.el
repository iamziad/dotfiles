;;; init-eglot.el --- Eglot configuration -*- lexical-binding: t; -*-

(use-package eglot
  :ensure t
  :defer t
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect nil)
  (eglot-report-progress nil)
  (eglot-extend-to-xref nil)
  (eglot-events-buffer-config '(:size 0))
  (eglot-stay-out-of '(flymake))

  :hook
  ((java-mode . eglot-ensure)
   (js-mode . eglot-ensure)
   (js-ts-mode . eglot-ensure)
   (c-mode . eglot-ensure)
   (c-ts-mode . eglot-ensure))

  :config
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (eglot-inlay-hints-mode -1)))

  :bind
  (:map eglot-mode-map
        ("C-c l r" . eglot-rename)
        ("C-c l o" . eglot-code-action-organize-imports)
        ("C-c l a" . eglot-code-actions)
        ("C-c l f" . eglot-format)
        ("C-c l d" . eldoc)
        ("C-c l q" . eglot-shutdown)
        ("C-c l R" . eglot-reconnect)))

(with-eval-after-load 'flycheck
  (global-flycheck-eglot-mode 1))

(provide 'init-eglot)
