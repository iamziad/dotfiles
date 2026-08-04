;;; mod-lsp.el --- LSP client (lsp-mode) -*- lexical-binding: t; -*-

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((c-ts-mode          . lsp-deferred)
         (c++-ts-mode        . lsp-deferred)
         (java-ts-mode       . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (js-ts-mode         . lsp-deferred)
         (tsx-ts-mode        . lsp-deferred)
         (html-ts-mode       . lsp-deferred)
         (css-ts-mode        . lsp-deferred)
         (go-ts-mode         . lsp-deferred)
	     (web-mode        . lsp-deferred)
         (bash-ts-mode       . lsp-deferred)
         (nix-mode       . lsp-deferred))
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-diagnostics-provider :flycheck)
  (lsp-completion-provider :capf)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-disabled-clients '(semgrep-ls))
  (lsp-eslint-server-command '("vscode-eslint-language-server" "--stdio"))
  ;; (lsp-clients-tsgo-path (executable-find "tsgo"))
  :bind (:map lsp-mode-map
              ("M-."     . lsp-find-definition)
              ("M-,"     . lsp-find-references)
              ("C-c l r" . lsp-rename)
              ("M-RET"   . lsp-execute-code-action)
              ("C-c l f" . lsp-format-buffer)
              ("C-c l b" . lsp-headerline-breadcrumb-mode)))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 0.3)
  (lsp-ui-sideline-show-diagnostics nil)
  :bind (:map lsp-ui-mode-map
              ("C-c l k" . lsp-ui-doc-glance)))

(use-package lsp-java
  :ensure t
  :after lsp-mode)

(provide 'mod-lsp)
;;; mod-lsp.el ends here
