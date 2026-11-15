;; ;; ;;; init-lsp.el --- Generic LSP configuration -*- lexical-binding: t; -*-

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (dired-mode . lsp-dired-mode)
         (c-mode          . lsp-deferred)
         (java-mode          . lsp-deferred)
         (js-ts-mode          . lsp-deferred)
         (json-ts-mode          . lsp-deferred)
         (typescript-ts-mode          . lsp-deferred)
         (tsx-ts-mode          . lsp-deferred)
         (web-mode          . lsp-deferred)
         (html-mode          . lsp-deferred)
         (css-mode          . lsp-deferred)
         )
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-completion-provider :none
        lsp-diagnostics-provider :flymake
        lsp-idle-delay 0.3
        lsp-enable-file-watchers t
        lsp-file-watch-threshold 10000
        lsp-enable-suggest-server-download nil
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
        lsp-enable-symbol-highlighting nil
        lsp-enable-on-type-formatting nil
        lsp-keep-workspace-alive t
        lsp-log-io nil
        lsp-use-plists t
        lsp-completion-show-detail t
        lsp-completion-show-kind t)
  :config
  (setq read-process-output-max (* 1024 1024))
  (keymap-set lsp-mode-map "M-RET" #'lsp-execute-code-action)
  (keymap-global-set "C-c l" lsp-command-map)
  :custom
  (lsp-java-configuration-runtimes
   '[(:name "JavaSE-21" :path "/usr/lib/jvm/java-21-openjdk")
     (:name "JavaSE-25" :path "/usr/lib/jvm/java-25-openjdk" :default t)])

  ;; JDTLS JVM arguments
  (lsp-java-vmargs
   '("-XX:+UseParallelGC"
     "-XX:GCTimeRatio=4"
     "-XX:AdaptiveSizePolicyWeight=90"
     "-Dsun.zip.disableMemoryMapping=true"
     "-Xmx2G"
     "-Xms100m")))

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

(use-package lsp-completion
  :ensure nil
  :hook (lsp-mode . lsp-completion-mode))

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
        lsp-ui-sideline-show-diagnostics nil
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-delay 0.5
        lsp-ui-peek-enable t)
  :bind (:map lsp-ui-mode-map
              ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
              ([remap xref-find-references] . lsp-ui-peek-find-references)))

;;; dap-mode --------------------------------------------------------------

(use-package dap-mode
  :ensure t
  :after lsp-mode
  :config
  (dap-auto-configure-mode))

(defvar-keymap my/debug-map
  :doc "Debugging commands (C-c d)."
  "d" #'dap-debug
  "b" #'dap-breakpoint-toggle
  "B" #'dap-breakpoint-delete-all
  "c" #'dap-continue
  "n" #'dap-next
  "i" #'dap-step-in
  "o" #'dap-step-out
  "r" #'dap-restart-frame
  "q" #'dap-disconnect
  "e" #'dap-eval
  "R" #'dap-ui-repl
  "I" #'dap-ui-inspect
  "l" #'dap-debug-last
  "L" #'dap-breakpoint-log-message
  "x" #'dap-breakpoint-expression)

(keymap-global-set "C-c d" my/debug-map)

;; Debugging
(with-eval-after-load 'dap-mode
  (require 'project)

  (defun my/dap-node ()
    "Debug a Node.js entry file in the current project."
    (interactive)
    (let* ((project (project-current nil))
           (root (file-name-as-directory
                  (expand-file-name
                   (if project
                       (project-root project)
                     default-directory))))
           (default-directory root)
           (program (expand-file-name
                     (read-file-name "Node entry file: "
                                     root nil t)
                     root)))
      (unless (file-regular-p program)
        (user-error "Node entry file does not exist: %s" program))

      (dap-debug
       (list :type "node"
             :request "launch"
             :name (format "Node: %s"
                           (file-name-nondirectory
                            (directory-file-name root)))
             :program program
             :cwd root)))))

(keymap-global-set "C-c d N" #'my/dap-node)

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

;;; LSP booster ----------------------------------------------------------------

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
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let* ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
            (setcar orig-result command-from-exec-path))
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))
(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

(provide 'init-lsp)
;; ;; ;;; init-lsp.el ends here
