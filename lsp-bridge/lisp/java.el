;;; java.el --- Java setup: formatting and jdtls debugging -*- lexical-binding: t; -*-

(setq java-ts-mode-indent-offset 4)

;;;; Formatting

(with-eval-after-load 'apheleia
  (setf (alist-get 'google-java-format apheleia-formatters)
        '("google-java-format" "--aosp" "-")))

;;;; Mason bundles

(defconst my/java-debug-plugin-globs
  '("packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
    "share/java-debug-adapter/com.microsoft.java.debug.plugin*.jar")
  "Where Mason may put the java-debug plugin jar, relative to `my/mason-dir'.")

(defconst my/java-test-jar-globs
  '("packages/java-test/extension/server/*.jar"
    "share/java-test/*.jar")
  "Where Mason may put the java-test jars, relative to `my/mason-dir'.")

(defconst my/java-test-jar-exclude-regexp
  "runner-jar-with-dependencies\\|jacocoagent"
  "Jars from java-test that jdtls must not load as bundles.")

(defun my/mason-glob (globs)
  "Return the existing files under `my/mason-dir' that match any of GLOBS."
  (seq-mapcat (lambda (glob)
                (file-expand-wildcards (expand-file-name glob my/mason-dir) t))
              globs))

(defun my/java-debug-bundles ()
  "Return the vector of jars jdtls must load to be debuggable.
Signal a `user-error' when java-debug-adapter is not installed in Mason."
  (let ((plugin (my/mason-glob my/java-debug-plugin-globs))
        (tests (seq-remove
                (lambda (jar)
                  (string-match-p my/java-test-jar-exclude-regexp jar))
                (my/mason-glob my/java-test-jar-globs))))
    (unless plugin
      (user-error "java-debug-adapter not found under %s (M-x mason-install RET java-debug-adapter)"
                  my/mason-dir))
    (vconcat plugin tests)))

;;;; Eglot + jdtls

(defun my/jdtls-contact (&rest _)
  "Return the Eglot contact for jdtls, with the Mason debug bundles attached.
Each project gets its own jdtls workspace directory."
  (let ((root (expand-file-name
               (if-let* ((project (project-current)))
                   (project-root project)
                 default-directory))))
    `("jdtls" "-data"
      ,(no-littering-expand-var-file-name
        (concat "jdtls-workspaces/" (md5 root)))
      :initializationOptions (:bundles ,(my/java-debug-bundles)))))

;; dape's jdtls debugging is built on Eglot.
(use-package eglot
  :straight nil
  :commands (eglot eglot-current-server eglot-shutdown)
  :custom (eglot-autoshutdown t)
  :config
  (add-to-list 'eglot-server-programs
               '((java-mode java-ts-mode) . my/jdtls-contact)))

;;;; Switching between lsp-bridge and Eglot

(defun my/java-debug-on ()
  "Use Eglot + jdtls (with Mason's java-debug bundle) in this Java buffer.
After this, `dape' can start the built-in `jdtls' configuration."
  (interactive)
  (unless (derived-mode-p 'java-mode 'java-ts-mode)
    (user-error "Not in a Java buffer"))
  (my/java-debug-bundles)               ; fail early if the adapter is missing
  (when (bound-and-true-p lsp-bridge-mode)
    (lsp-bridge-mode -1))
  (call-interactively #'eglot))

(defun my/java-debug-off ()
  "Stop Eglot in this buffer and go back to lsp-bridge."
  (interactive)
  (when-let* ((server (eglot-current-server)))
    (eglot-shutdown server)
    (flymake-mode -1))
  (lsp-bridge-mode 1))

(keymap-set my/debug-map "j" #'my/java-debug-on)
(keymap-set my/debug-map "J" #'my/java-debug-off)

(provide 'java)
;;; java.el ends here
