;; -*- lexical-binding: t; -*-

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-auto-guess-root t
        lsp-completion-provider :capf
        lsp-diagnostics-provider :flycheck
        lsp-headerline-breadcrumb-enable nil
        lsp-modeline-code-actions-enable t
        lsp-modeline-diagnostics-enable t
        lsp-modeline-workspace-status-enable t
        lsp-enable-snippet t
        lsp-enable-on-type-formatting nil
        lsp-enable-symbol-highlighting t
        lsp-enable-file-watchers t
        lsp-file-watch-threshold 3000
        lsp-idle-delay 0.5
        lsp-log-io nil
        lsp-keep-workspace-alive nil
        lsp-restart 'auto-restart
        lsp-response-timeout 15
        lsp-signature-auto-activate t
        lsp-eldoc-enable-hover t
        eldoc-echo-area-use-multiline-p nil)

  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (dired-mode         . lsp-dired-mode)
         (c-mode             . lsp-deferred)
         (java-mode          . lsp-deferred)
         (js-ts-mode         . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (tsx-ts-mode        . lsp-deferred)
         (html-mode          . lsp-deferred)
         (css-mode           . lsp-deferred)
         )
  :custom
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  :config
  (setq read-process-output-max (* 1024 1024))

  (with-eval-after-load 'lsp-mode
    (setq lsp-disabled-clients '(semgrep-ls)))

  (dolist (dir '("[/\\\\]\\.angular\\'" "[/\\\\]\\.next\\'" "[/\\\\]\\.nuxt\\'"
                 "[/\\\\]\\.cache\\'" "[/\\\\]coverage\\'" "[/\\\\]dist\\'"
                 "[/\\\\]build\\'" "[/\\\\]out\\'" "[/\\\\]target\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories dir))
  :init
  :bind (:map lsp-mode-map
              ("M-RET" . lsp-execute-code-action)))

(use-package lsp-ui
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-show-with-mouse t)
  (lsp-ui-doc-delay 1.5)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-max-height 15)
  (lsp-ui-doc-max-width 75)
  (lsp-ui-doc-use-childframe t)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-peek-list-width 30)
  (lsp-ui-peek-peek-height 18)
  :bind (:map lsp-ui-mode-map
              ("C-c l k" . lsp-ui-doc-glance)))

(use-package lsp-treemacs
  :after lsp)

(provide 'init-lsp-mode)
