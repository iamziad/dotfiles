;; -*- lexical-binding: t; -*-

(use-package mason
  :config
  (mason-ensure
   (lambda ()
     (dolist (pkg '("clangd" "jdtls" "typescript-language-server"
                    "bash-language-server" "html-lsp" "css-lsp" "json-lsp"
                    "prettier" "clang-format" "google-java-format"))
       (unless (mason-installed-p pkg)
         (ignore-errors (mason-install pkg)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package lsp-mode
  :diminish "LSP"
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (dired-mode . lsp-dired-mode)
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
  ;; abuse Eldoc
  (lsp-eldoc-enable-hover t)
  (lsp-eldoc-render-all t)
  (lsp-signature-auto-activate t)
  (lsp-signature-render-documentation t)
  (eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  ;;
  (lsp-semantic-tokens-enable nil)
  (lsp-enable-dap-auto-configure t)
  :bind
  (:map lsp-mode-map
        ("M-RET" . lsp-execute-code-action)
        ("C-c l a" . lsp-execute-code-action)
        ("C-c l b" . lsp-headerline-breadcrumb-mode)
        ("C-c l d" . lsp-find-definition)
        ("C-c l r" . lsp-find-references)
        ("C-c l i" . lsp-find-implementation)
        ("C-c l t" . lsp-find-type-definition)
        ("C-c l h" . lsp-describe-thing-at-point)
        ("C-c l R" . lsp-rename)
        ("C-c l s" . lsp-signature-activate)
        ("C-c l f" . lsp-format-buffer)
        ("C-c l F" . lsp-format-region)
        ("C-c l e" . lsp-ui-flycheck-list))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my/lsp-booster-json-parse (old-fn &rest args)
  "Read the booster's bytecode instead of JSON when it is present."
  (or (when (equal (following-char) ?#)
        (let ((bytecode (read (current-buffer))))
          (when (byte-code-function-p bytecode)
            (funcall bytecode))))
      (apply old-fn args)))
(advice-add 'json-parse-buffer :around #'my/lsp-booster-json-parse)

(defun my/lsp-booster-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster to the server command."
  (let ((orig (funcall old-fn cmd test?)))
    (if (and (not test?)
             (not (file-remote-p default-directory))
             lsp-use-plists
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let* ((resolved (executable-find (car orig))))
            (setcar orig resolved))
          (cons "emacs-lsp-booster" orig))
      orig)))
(advice-add 'lsp-resolve-final-command :around #'my/lsp-booster-final-command)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'lsp-diagnostics-mode-hook
          (lambda ()
            (when (flycheck-valid-checker-p 'lsp)
              (flycheck-add-next-checker 'lsp 'javascript-eslint))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package lsp-java
  :after lsp-mode
  :config
  ;;
  (setq lsp-java-server-install-dir (expand-file-name "packages/jdtls/" mason-dir))
  ;;
  (let ((jvm "/usr/lib/jvm/java-25-openjdk"))
    (when (file-directory-p jvm)
      (setq lsp-java-java-path (concat jvm "/bin/java")
            lsp-java-configuration-runtimes
            `[(:name "JavaSE-25" :path ,jvm :default t)])))
  ;;
  (let ((dap-jar (expand-file-name
                  "share/java-debug-adapter/com.microsoft.java.debug.plugin.jar"
                  mason-dir)))
    (when (file-exists-p dap-jar)
      (setq lsp-java-bundles (list (file-truename dap-jar))))))

(provide 'mod-lsp)
