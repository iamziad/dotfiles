;;; mod-lsp.el -*- lexical-binding: t; -*-

(require 'cl-lib)

(defvar my/lsp--default-read-process-output-max nil)
(defvar my/lsp--default-gcmh-high-cons-threshold nil)
(defvar my/lsp--optimization-active nil)

(define-minor-mode my/lsp-optimization-mode
  nil
  :global t
  (if my/lsp-optimization-mode
      (unless my/lsp--optimization-active
        (setq my/lsp--default-read-process-output-max (default-value 'read-process-output-max))
        (setq-default read-process-output-max (* 1024 1024))
        (when (bound-and-true-p gcmh-mode)
          (setq my/lsp--default-gcmh-high-cons-threshold gcmh-high-cons-threshold
                gcmh-high-cons-threshold (* 2 gcmh-high-cons-threshold))
          (gcmh-set-high-threshold))
        (setq my/lsp--optimization-active t))
    (when my/lsp--optimization-active
      (setq-default read-process-output-max my/lsp--default-read-process-output-max)
      (when (bound-and-true-p gcmh-mode)
        (setq gcmh-high-cons-threshold my/lsp--default-gcmh-high-cons-threshold))
      (setq my/lsp--optimization-active nil))))

(defvar my/lsp-defer-shutdown 3)
(defvar my/lsp--deferred-shutdown-timer nil)

(defun my/lsp--defer-server-shutdown-a (fn &optional restart)
  (if (or lsp-keep-workspace-alive
          restart
          (null my/lsp-defer-shutdown)
          (= my/lsp-defer-shutdown 0))
      (funcall fn restart)
    (when (timerp my/lsp--deferred-shutdown-timer)
      (cancel-timer my/lsp--deferred-shutdown-timer))
    (setq my/lsp--deferred-shutdown-timer
          (run-at-time
           my/lsp-defer-shutdown nil
           (lambda (workspaces)
             (dolist (ws workspaces)
               (or (cl-some #'lsp-buffer-live-p (lsp--workspace-buffers ws))
                   (with-lsp-workspace ws
                     (let ((lsp-restart 'ignore))
                       (funcall fn))))))
           lsp--buffer-workspaces))))

(use-package lsp-mode
  :diminish "LSP"
  :ensure t
  :hook ((c-ts-mode          . lsp-deferred)
         (c++-ts-mode        . lsp-deferred)
         (java-ts-mode       . lsp-deferred)
         (js-ts-mode         . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (json-ts-mode       . lsp-deferred)
         (tsx-ts-mode        . lsp-deferred)
         (html-ts-mode       . lsp-deferred)
         (css-ts-mode        . lsp-deferred)
         (go-ts-mode         . lsp-deferred)
         (web-mode           . lsp-deferred)
         (bash-ts-mode       . lsp-deferred)
         (nix-mode           . lsp-deferred))
  :bind (:map lsp-mode-map
              ("M-."     . lsp-find-definition)
              ("M-,"     . lsp-find-references)
              ("C-c l r" . lsp-rename)
              ("M-RET"   . lsp-execute-code-action)
              ("C-c l f" . lsp-format-buffer)
              ("C-c l b" . lsp-headerline-breadcrumb-mode))
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-completion-provider :none)
  (lsp-diagnostics-provider :flycheck)
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-log-io nil)
  (lsp-keep-workspace-alive nil)
  (lsp-idle-delay 0.1)
  (lsp-enable-xref t)
  (lsp-auto-configure t)
  (lsp-eldoc-enable-hover t)
  (lsp-enable-dap-auto-configure t)
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)
  (lsp-enable-imenu t)
  (lsp-enable-indentation nil)
  (lsp-enable-links nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-suggest-server-download t)
  (lsp-enable-symbol-highlighting t)
  (lsp-enable-text-document-color nil)

  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-diagnostic-max-lines 20)
  (lsp-completion-enable t)
  (lsp-completion-enable-additional-text-edit t)
  (lsp-enable-snippet t)
  (lsp-completion-show-kind t)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-modeline-workspace-status-enable nil)
  (lsp-signature-doc-lines 1)
  (lsp-ui-doc-use-childframe t)
  (lsp-eldoc-render-all nil)
  (lsp-semantic-tokens-enable nil)

  :init
  (setq lsp-use-plists t)

  :config
  (advice-add 'lsp--shutdown-workspace :around #'my/lsp--defer-server-shutdown-a)
  (add-hook 'lsp-before-initialize-hook #'my/lsp-optimization-mode)
  (add-hook 'lsp-after-uninitialized-functions
            (lambda (_workspace)
              (unless (lsp--session-workspaces lsp--session)
                (my/lsp-optimization-mode -1)))))

(use-package lsp-completion
  :straight nil
  :hook ((lsp-mode . lsp-completion-mode)))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor nil)
  (lsp-ui-doc-show-with-mouse nil)
  (lsp-ui-doc-delay 0.2)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-max-height 8)
  (lsp-ui-doc-max-width 72)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-sideline-show-diagnostics nil)
  :bind (:map lsp-ui-mode-map
              ("C-c l k" . lsp-ui-doc-glance)))

(use-package dap-mode
  :after lsp-mode
  :config
  (dap-auto-configure-mode)
  :bind (("<f7>" . dap-step-in)
         ("<f8>" . dap-next)
         ("<f9>" . dap-continue)))

(use-package lsp-java
  :ensure t
  :after lsp-mode)

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))
(advice-add (if (progn (require 'json)
                       (fboundp 'json-parse-buffer))
                'json-parse-buffer
              'json-read)
            :around
            #'lsp-booster--advice-json-parse)

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)
             (not (file-remote-p default-directory))
             lsp-use-plists
             (not (functionp 'json-rpc-connection))
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((command-from-exec-path (executable-find (car orig-result))))
            (setcar orig-result command-from-exec-path))
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))
(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

(provide 'mod-lsp)
