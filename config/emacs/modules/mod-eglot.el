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
  :config
  (setq eglot-ignored-server-capabilities '(:semanticTokensProvider :documentHighlightProvider))
  (setq eglot-sync-connect nil)
  :bind (:map eglot-mode-map
              ("M-."     . xref-find-definitions)
              ("M-,"     . xref-find-references)
              ("C-c l r" . eglot-rename)
              ("M-RET"   . eglot-code-actions)
              ("C-c l k" . eldoc-box-help-at-point)))

;; ;; Left and right side windows occupy full frame height
(use-package emacs
  :custom
  (window-sides-vertical t))

(use-package flycheck-eglot
  :ensure t
  :after (flycheck eglot)
  :config
  (global-flycheck-eglot-mode 1))

(use-package flycheck-inline
  :ensure t
  :hook
  (flycheck-eglot-mode . flycheck-inline-mode))

;; (use-package repeat
;;   :custom
;;   (repeat-mode +1))

;; ;; Debuging

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((java-mode java-ts-mode) .
                 ("jdtls"
                  :initializationOptions
                  (:bundles ["/home/ziad/.m2/repository/com/microsoft/java/com.microsoft.java.debug.plugin/0.53.2/com.microsoft.java.debug.plugin-0.53.2.jar"])))))


(provide 'mod-eglot)
;;; mod-eglot.el ends here
