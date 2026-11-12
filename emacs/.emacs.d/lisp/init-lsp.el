;;; init-lsp.el --- Generic LSP configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Language-agnostic lsp-mode setup.  Language specific files
;; (lang-java.el, lang-web.el) only add hooks and server settings.
;; lsp-mode is used instead of Eglot because lsp-java provides the
;; JDT LS integration, Java-specific commands and DAP debugging.

;;; Code:

(require 'json)
(require 'subr-x)

;;; Optional JSON acceleration -------------------------------------------------

(defun my/lsp-booster-json-advice (old-fn &rest args)
  "Parse emacs-lsp-booster's bytecode JSON responses."
  (or (when (equal (following-char) ?#)
        (let ((bytecode (read (current-buffer))))
          (when (byte-code-function-p bytecode)
            (funcall bytecode))))
      (apply old-fn args)))

(defun my/lsp-booster-command-advice (old-fn command &optional test?)
  "Wrap COMMAND with emacs-lsp-booster when it is available."
  (let ((result (funcall old-fn command test?)))
    (if (and (not test?)
             (not (file-remote-p default-directory))
             (not (functionp 'json-rpc-connection))
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((resolved (executable-find (car result))))
            (setcar result resolved))
          (cons "emacs-lsp-booster"
                (append (unless lsp-use-plists
                          ;; Keep the booster's output in sync with lsp-mode's
                          ;; JSON representation.  A mismatch makes every
                          ;; notification fail with `wrong-type-argument
                          ;; hash-table-p'.
                          (list "--json-object-type" "hashtable" "--"))
                        result)))
      result)))

(when (executable-find "emacs-lsp-booster")
  (advice-add (if (fboundp 'json-parse-buffer) 'json-parse-buffer 'json-read)
              :around #'my/lsp-booster-json-advice))

;;; lsp-mode ------------------------------------------------------------------

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-completion-provider :none
        lsp-diagnostics-provider :flycheck
        lsp-idle-delay 0.3
        lsp-enable-file-watchers t
        lsp-file-watch-threshold 10000
        lsp-enable-suggest-server-download nil
        lsp-auto-guess-root t
        lsp-restart 'auto-restart
        lsp-enable-snippet t
        lsp-signature-auto-activate t
        lsp-signature-render-documentation nil
        lsp-headerline-breadcrumb-enable t
        lsp-modeline-code-actions-enable t
        lsp-modeline-diagnostics-enable t
        lsp-modeline-workspace-status-enable t
        lsp-lens-enable t
        lsp-semantic-tokens-enable t
        lsp-enable-symbol-highlighting t
        lsp-enable-on-type-formatting t
        lsp-keep-workspace-alive t
        lsp-log-io nil
        ;; Keep this nil: the installed lsp-mode/lsp-java bytecode is
        ;; compiled for hash tables.  Changing it requires recompiling
        ;; those packages, otherwise notifications fail with
        ;; `wrong-type-argument hash-table-p'.
        lsp-use-plists nil
        lsp-completion-show-detail t
        lsp-completion-show-kind t)
  :config
  (setq read-process-output-max (* 1024 1024))
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (keymap-set lsp-mode-map "M-RET" #'lsp-execute-code-action)
  (keymap-set lsp-mode-map "C-c r" #'lsp-rename)
  (keymap-global-set "C-c l" lsp-command-map)
  (when (executable-find "emacs-lsp-booster")
    (advice-add 'lsp-resolve-final-command :around #'my/lsp-booster-command-advice)))

;; File watchers are useful (pom.xml, build.gradle, package.json changes),
;; but heavy directories must be excluded or Node/Java projects get slow.
(with-eval-after-load 'lsp-mode
  (dolist (re '("[/\\\\]node_modules\\'"
                "[/\\\\]\\.git\\'"
                "[/\\\\]target\\'"
                "[/\\\\]build\\'"
                "[/\\\\]dist\\'"
                "[/\\\\]\\.gradle\\'"
                "[/\\\\]\\.idea\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re)))

;;; lsp-ui --------------------------------------------------------------------

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :init
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-delay 1.0
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-max-width 100
        lsp-ui-doc-max-height 30
        lsp-ui-doc-show-with-cursor nil
        lsp-ui-doc-show-with-mouse t
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-sideline-delay 0.5
        lsp-ui-peek-enable t)
  :bind (:map lsp-ui-mode-map
              ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
              ([remap xref-find-references] . lsp-ui-peek-find-references)))

;;; lsp-treemacs --------------------------------------------------------------

(use-package lsp-treemacs
  :ensure t
  :after lsp-mode
  :commands (lsp-treemacs-errors-list lsp-treemacs-symbols))

;;; Mode line ----------------------------------------------------------------

;; Show just the language server name instead of its full workspace path.
(defun my/lsp-workspace-print (workspace)
  "Return a short description of WORKSPACE for the mode line."
  (symbol-name
   (lsp--client-server-id
    (lsp--workspace-client workspace))))

(with-eval-after-load 'lsp-mode
  (when (and (fboundp 'lsp--workspace-client)
             (fboundp 'lsp--client-server-id))
    (advice-add #'lsp--workspace-print :override #'my/lsp-workspace-print)))

(provide 'init-lsp)
;;; init-lsp.el ends here
