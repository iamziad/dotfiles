;;; mod-lsp.el --- LSP setup -*- lexical-binding: t; -*-

(use-package lsp-mode
  :diminish "LSP"
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (c-ts-mode          . lsp-deferred)
         (c++-ts-mode        . lsp-deferred)
         (java-ts-mode       . lsp-deferred)
         (js-ts-mode         . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (json-ts-mode       . lsp-deferred)
         (tsx-ts-mode        . lsp-deferred)
         (html-ts-mode       . lsp-deferred)
         (css-ts-mode        . lsp-deferred)
         (go-ts-mode         . lsp-deferred)
         (bash-ts-mode       . lsp-deferred)
         (sql-mode           . lsp-deferred))
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-completion-provider :none)            ; corfu + cape handle completion
  (lsp-diagnostics-provider :flycheck)
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-idle-delay 0.1)
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)
  (lsp-enable-indentation nil)
  (lsp-enable-links nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-symbol-highlighting t)
  (lsp-enable-text-document-color nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-modeline-workspace-status-enable nil)
  (lsp-signature-doc-lines 1)
  (lsp-eldoc-render-all nil)
  (lsp-semantic-tokens-enable nil)
  (lsp-enable-dap-auto-configure t)
  :init
  (setq lsp-use-plists t)
  :bind (:map lsp-mode-map
              ("M-RET" . lsp-execute-code-action)))

(use-package lsp-completion
  :straight nil
  :hook (lsp-mode . lsp-completion-mode))

(use-package lsp-ui
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
  (lsp-ui-doc-use-childframe t)
  (lsp-ui-sideline-enable nil)
  :bind (:map lsp-ui-mode-map
              ("C-c l k" . lsp-ui-doc-glance)))

(use-package lsp-java
  :after lsp-mode
  :config
  (setq lsp-java-server-install-dir (expand-file-name "~/.local/share/jdtls-local/")
        lsp-java-java-path "/usr/lib/jvm/java-25-openjdk/bin/java"
        lsp-java-configuration-runtimes
        '[(:name "JavaSE-25"
                 :path "/usr/lib/jvm/java-25-openjdk"
                 :default t)])
  (let ((dap-jar "/home/ziad/.m2/repository/com/microsoft/java/com.microsoft.java.debug.plugin/0.53.2/com.microsoft.java.debug.plugin-0.53.2.jar"))
    (when (file-exists-p dap-jar)
      (setq lsp-java-bundles (list dap-jar)))))

;; emacs-lsp-booster: faster JSON parsing from language servers.
;; Only active when the `emacs-lsp-booster' binary is on PATH.
(when (executable-find "emacs-lsp-booster")
  (defun my/lsp-booster--json-parse (old-fn &rest args)
    "Read bytecode from the booster instead of JSON when present."
    (or (when (equal (following-char) ?#)
          (let ((bytecode (read (current-buffer))))
            (when (byte-code-function-p bytecode)
              (funcall bytecode))))
        (apply old-fn args)))
  (advice-add (if (fboundp 'json-parse-buffer) 'json-parse-buffer 'json-read)
              :around #'my/lsp-booster--json-parse)

  (defun my/lsp-booster--final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster to the server command."
    (let ((orig (funcall old-fn cmd test?)))
      (if (and (not test?)
               (not (file-remote-p default-directory))
               lsp-use-plists)
          (progn
            (when-let* ((resolved (executable-find (car orig))))
              (setcar orig resolved))
            (cons "emacs-lsp-booster" orig))
        orig)))
  (advice-add 'lsp-resolve-final-command :around #'my/lsp-booster--final-command))

(provide 'mod-lsp)
;;; mod-lsp.el ends here
