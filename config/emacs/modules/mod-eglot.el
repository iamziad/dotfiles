;;; mod-eglot.el --- LSP client (eglot) -*- lexical-binding: t; -*-

(use-package eglot
  :straight nil
  :hook ((c-ts-mode          . eglot-ensure)
         (c++-ts-mode        . eglot-ensure)
         (java-ts-mode       . eglot-ensure)
         (js-ts-mode         . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (json-ts-mode       . eglot-ensure)
         (tsx-ts-mode        . eglot-ensure)
         (html-ts-mode       . eglot-ensure)
         (css-ts-mode        . eglot-ensure)
         (go-ts-mode         . eglot-ensure)
         (web-mode           . eglot-ensure)
         (bash-ts-mode       . eglot-ensure)
         (nix-mode           . eglot-ensure))
  :bind (:map eglot-mode-map
              ("M-."     . xref-find-definitions)
              ("M-,"     . xref-find-references)
              ("C-c l r" . eglot-rename)
              ("M-RET"   . eglot-code-actions)
              ("C-c l k" . eldoc-box-help-at-point))
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect nil)
  (eglot-events-buffer-size 0)
  (eglot-extend-to-xref t)
  (eglot-ignored-server-capabilities '(:documentHighlightProvider))
  )

;; (use-package flycheck-eglot
;;   :ensure t
;;   :after (flycheck eglot)
;;   :config
;;   (global-flycheck-eglot-mode 1))

(provide 'mod-eglot)
;;; mod-eglot.el ends here
