;;; mod-lsp.el --- LSP client (lsp-mode) -*- lexical-binding: t; -*-

;; (use-package lsp-mode
;;   :hook ((c-ts-mode . lsp-deferred)
;;          (c++-ts-mode . lsp-deferred)
;;          (java-ts-mode . lsp-deferred)
;;          (python-ts-mode . lsp-deferred)
;;          (go-ts-mode . lsp-deferred)
;;          (js-ts-mode . lsp-deferred)
;;          (typescript-ts-mode . lsp-deferred)
;;          (tsx-ts-mode . lsp-deferred)
;;          (web-mode . lsp-deferred)
;;          (html-mode . lsp-deferred)
;;          (html-ts-mode . lsp-deferred)
;;          (css-mode . lsp-deferred)
;;          (css-ts-mode . lsp-deferred))
;;   :commands lsp
;;   :bind (:map lsp-mode-map
;;               ("M-."     . lsp-find-definition)
;;               ("M-,"     . lsp-find-references)
;;               ("C-c l r" . lsp-rename)
;;               ("M-RET"   . lsp-execute-code-action)
;;               ("C-c l f" . lsp-format-buffer)
;;               ("C-c l b" . lsp-headerline-breadcrumb-mode))
;;   :config (setq lsp-idle-delay 1)
;;   :init
;;   (setq lsp-keymap-prefix "C-c l")
;;   (setq lsp-diagnostics-provider :flycheck))

;; (use-package lsp-ui
;;   :after lsp-mode
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :custom
;;   (lsp-ui-doc-enable t)
;;   (lsp-ui-sideline-enable nil)) ; sideline gets noisy fast; doc popups are enough

;; https://www.ovistoica.com/blog/2024-7-05-modern-emacs-typescript-web-tsx-config#orgc542f94
(use-package lsp-mode
  :ensure t
  :hook ((lsp-mode . lsp-diagnostics-mode)
         (lsp-mode . lsp-enable-which-key-integration)
         ((c-ts-mode c++-ts-mode java-ts-mode
                     bash-ts-mode go-ts-mode tsx-ts-mode
                     typescript-ts-mode js-ts-mode html-ts-mode
                     css-ts-mode web-mode json-ts-mode) . lsp-deferred))
  :custom
  (lsp-keymap-prefix "C-c l")           ; Prefix for LSP actions
  (lsp-completion-provider :none)       ; Using Corfu as the provider
  (lsp-diagnostics-provider :flycheck)
  ;; (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-log-io nil)                      ; IMPORTANT! Use only for debugging! Drastically affects performance
  (lsp-keep-workspace-alive nil)        ; Close LSP server if all project buffers are closed
  (lsp-idle-delay 0.5)                  ; Debounce timer for `after-change-function'
  ;; core
  (lsp-enable-xref t)                   ; Use xref to find references
  (lsp-auto-configure t)                ; Used to decide between current active servers
  (lsp-eldoc-enable-hover t)            ; Display signature information in the echo area
  (lsp-enable-dap-auto-configure t)     ; Debug support
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)
  (lsp-enable-imenu t)
  (lsp-enable-indentation nil)          ; I use prettier
  (lsp-enable-on-type-formatting nil)   ; Prettier handles this
  (lsp-enable-suggest-server-download t) ; Useful prompt to download LSP providers
  (lsp-enable-symbol-highlighting t)     ; Shows usages of symbol at point in the current buffer
  (lsp-enable-text-document-color nil)   ; This is Treesitter's job

  (lsp-ui-sideline-show-hover nil)      ; Sideline used only for diagnostics
  (lsp-ui-sideline-diagnostic-max-lines 20) ; 20 lines since typescript errors can be quite big
  ;; completion
  (lsp-completion-enable t)
  (lsp-completion-enable-additional-text-edit t) ; Ex: auto-insert an import for a completion candidate
  (lsp-enable-snippet t)                         ; Important to provide full JSX completion
  (lsp-completion-show-kind t)                   ; Optional
  ;; headerline
  (lsp-headerline-breadcrumb-enable t)  ; Optional, I like the breadcrumbs
  (lsp-headerline-breadcrumb-enable-diagnostics nil) ; Don't make them red, too noisy
  (lsp-headerline-breadcrumb-enable-symbol-numbers nil)
  (lsp-headerline-breadcrumb-icons-enable nil)
  ;; modeline
  (lsp-modeline-code-actions-enable nil) ; Modeline should be relatively clean
  (lsp-modeline-diagnostics-enable nil)  ; Already supported through `flycheck'
  (lsp-modeline-workspace-status-enable nil) ; Modeline displays "LSP" when lsp-mode is enabled
  (lsp-signature-doc-lines 1)                ; Don't raise the echo area. It's distracting
  (lsp-ui-doc-use-childframe t)              ; Show docs for symbol at point
  (lsp-eldoc-render-all nil)            ; This would be very useful if it would respect `lsp-signature-doc-lines', currently it's distracting
  ;; semantic
  (lsp-semantic-tokens-enable nil)      ; Related to highlighting, and we defer to treesitter

  :init
  (setq lsp-use-plists t))

(use-package lsp-completion
  :straight nil
  :hook ((lsp-mode . lsp-completion-mode)))

(use-package lsp-ui
  :ensure t
  :commands
  (lsp-ui-doc-show
   lsp-ui-doc-glance)
  :bind (:map lsp-mode-map
              ("C-c C-d" . 'lsp-ui-doc-glance))
  :config (setq lsp-ui-doc-enable t
                lsp-ui-doc-show-with-cursor nil      ; Don't show doc when cursor is over symbol - too distracting
                lsp-ui-doc-include-signature t       ; Show signature
                lsp-ui-doc-position 'at-point))


;; JS/TS
(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode . "typescriptreact"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("tsc" "--lsp" "--stdio"))
    :major-modes '(typescript-ts-mode tsx-ts-mode)
    :server-id 'tsc-lsp
    :priority 10)))


;; Java
(use-package lsp-java
  :ensure t
  :after lsp-mode)



;; TypeScript 7.0 (July 2026) rewrote tsserver in Go and dropped
;; tsserver.js, breaking typescript-language-server (which drives
;; tsserver.js under the hood) - lsp-mode's bundled ts-ls client inherits
;; the same problem. Point it at the compiler's own LSP mode instead.
;;
;; Best-effort registration - lsp-mode's client API moves around between
;; versions, so verify with `M-x lsp-describe-session' that `tsc-lsp'
;; (not the stock `ts-ls') is the client actually attached in a .ts buffer.


(provide 'mod-lsp)
;;; mod-lsp.el ends here
