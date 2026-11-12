;;; init-java.el --- Java IDE support -*- lexical-binding: t; -*-

;;; Commentary:
;; Java is handled by Eclipse JDT LS through lsp-java.  The language
;; server is kept inside this configuration directory so it is easy to
;; find, update, or remove.
;;
;; The server must be a full JDT LS installation (not just the launcher
;; jar) because lsp-java also loads the java-debug plugin and the JUnit
;; runner from it.

;;; Code:

(require 'project)
(require 'subr-x)
(require 'seq)

;;; Paths ---------------------------------------------------------------------

(defconst my/java--config-dir (expand-file-name "var/lsp-java/" user-emacs-directory)
  "Directory for JDT LS state.")

(defconst my/java--jdtls-root (expand-file-name "eclipse.jdt.ls/" my/java--config-dir)
  "Root of the JDT LS installation.")

(defconst my/java--jdtls-dir (expand-file-name "server/" my/java--jdtls-root)
  "JDT LS server directory (contains plugins/ and config_linux/).")

(defconst my/java--workspace-dir (expand-file-name "workspace/" my/java--config-dir)
  "JDT LS workspace directory.")

(defconst my/java--test-runner
  (expand-file-name "test-runner/junit-platform-console-standalone.jar" my/java--jdtls-root)
  "JUnit runner used by dap-java.")

;;; JDK discovery -------------------------------------------------------------

(defvar my/java--home-cache nil
  "Cached JDK home directory.")

(defun my/java--read-release-version (home)
  "Return the major Java version recorded in HOME/release, or nil."
  (let ((release (expand-file-name "release" home)))
    (when (file-readable-p release)
      (with-temp-buffer
        (insert-file-contents release)
        (goto-char (point-min))
        (when (re-search-forward "^JAVA_VERSION=\"\\([0-9]+\\)" nil t)
          (string-to-number (match-string 1)))))))

(defun my/java--detect-home ()
  "Find a usable JDK home directory."
  (or (getenv "JAVA_HOME")
      (seq-find (lambda (dir)
                  (file-executable-p (expand-file-name "bin/java" dir)))
                '("/usr/lib/jvm/java-25-openjdk-amd64"
                  "/usr/lib/jvm/java-21-openjdk-amd64"
                  "/usr/lib/jvm/default-java"))
      (when-let ((java (executable-find "java")))
        (with-temp-buffer
          (call-process java nil t nil "-XshowSettings:properties" "-version")
          (goto-char (point-min))
          (when (re-search-forward "^[[:space:]]*java.home = \\(.+\\)$" nil t)
            (string-trim (match-string 1)))))))

(defun my/java-home ()
  "Return the JDK home directory used by Emacs."
  (or my/java--home-cache
      (setq my/java--home-cache (my/java--detect-home))))

(defun my/java-executable ()
  "Return the Java executable used by Emacs."
  (let ((home (my/java-home)))
    (if home
        (expand-file-name "bin/java" home)
      "java")))

(defun my/java--runtimes ()
  "Build `lsp-java-configuration-runtimes' from installed JDKs."
  (let* ((default-home (my/java-home))
         (homes (delete-dups
                 (delq nil
                       (list default-home
                             "/usr/lib/jvm/java-25-openjdk-amd64"
                             "/usr/lib/jvm/java-21-openjdk-amd64"))))
         (runtimes
          (delq nil
                (mapcar
                 (lambda (home)
                   (when (file-directory-p home)
                     (when-let ((version (my/java--read-release-version home)))
                       (list :name (format "JavaSE-%s" version)
                             :path home
                             :default (equal home default-home)))))
                 homes))))
    (vconcat runtimes)))

;;; JDT LS --------------------------------------------------------------------

(use-package lsp-java
  :ensure t
  :defer t
  :init
  (setq lsp-java-server-install-dir my/java--jdtls-dir
        lsp-java-workspace-dir my/java--workspace-dir
        lsp-java-workspace-cache-dir (expand-file-name ".cache/" my/java--workspace-dir)
        lsp-java-java-path (my/java-executable)
        lsp-java-configuration-runtimes (my/java--runtimes)
        lsp-java-vmargs '("-XX:+UseParallelGC"
                          "-XX:GCTimeRatio=4"
                          "-XX:AdaptiveSizePolicyWeight=90"
                          "-Dsun.zip.disableMemoryMapping=true"
                          "-Xmx2G"
                          "-Xms200m")
        lsp-java-format-enabled t
        lsp-java-save-actions-organize-imports t
        lsp-java-completion-guess-method-arguments t
        lsp-java-signature-help-enabled t
        lsp-java-references-code-lens-enabled t
        lsp-java-implementations-code-lens-enabled nil
        lsp-java-autobuild-enabled t
        lsp-java-import-maven-enabled t
        lsp-java-import-gradle-enabled t
        lsp-java-maven-download-sources nil))

;;; DAP (Java side) -----------------------------------------------------------

;; dap-java commands are used from the keymap before dap-java is loaded.
(dolist (fn '(dap-java-debug
              dap-java-run-test-method
              dap-java-debug-test-method
              dap-java-run-test-class
              dap-java-debug-test-class))
  (autoload fn "dap-java" nil t))

(with-eval-after-load 'dap-java
  (setq dap-java-java-command (my/java-executable))
  (when (file-readable-p my/java--test-runner)
    (setq dap-java-test-runner my/java--test-runner)))

;;; Buffer setup --------------------------------------------------------------

(defvar my/java-format-on-save t
  "Whether to format Java buffers with JDT LS before saving.")

(defun my/java-format-on-save ()
  "Format the current Java buffer before saving, when possible."
  (when (and my/java-format-on-save
             (bound-and-true-p lsp-mode)
             (lsp-workspaces)
             (lsp-feature? "textDocument/formatting"))
    (condition-case err
        (lsp-format-buffer)
      (error (message "Java format on save failed: %s" err)))))

(defun my/java-mode-setup ()
  "Configure the current Java buffer and start JDT LS."
  (setq-local c-basic-offset 4
              tab-width 4
              indent-tabs-mode nil
              fill-column 100
              comment-column 40)
  (add-hook 'before-save-hook #'my/java-format-on-save nil t)
  (require 'lsp-java)
  (lsp-deferred))

(add-hook 'java-mode-hook #'my/java-mode-setup)
(add-hook 'java-ts-mode-hook #'my/java-mode-setup)

;;; Build and run -------------------------------------------------------------

(defun my/java--project-root ()
  "Return the current project root, or nil."
  (when-let ((project (project-current)))
    (project-root project)))

(defun my/java--build-tool (root)
  "Return the build tool used by ROOT: `maven', `gradle' or nil."
  (cond
   ((file-exists-p (expand-file-name "pom.xml" root)) 'maven)
   ((or (file-exists-p (expand-file-name "build.gradle" root))
        (file-exists-p (expand-file-name "build.gradle.kts" root))) 'gradle)
   (t nil)))

(defun my/java--compile-command (root file)
  "Return a shell command that compiles FILE in ROOT."
  (pcase (my/java--build-tool root)
    ('maven (if (file-executable-p (expand-file-name "mvnw" root))
                "./mvnw -q -DskipTests compile"
              "mvn -q -DskipTests compile"))
    ('gradle (if (file-executable-p (expand-file-name "gradlew" root))
                 "./gradlew compileJava"
               "gradle compileJava"))
    (_ (let ((output (expand-file-name "target/classes" root)))
         (make-directory output t)
         (format "javac -d %s %s"
                 (shell-quote-argument output)
                 (shell-quote-argument (or file "")))))))

(defun my/java-compile ()
  "Compile the current Java project.
Uses the JDT LS incremental builder when the server is running,
otherwise falls back to the project's build tool or javac."
  (interactive)
  (if (and (bound-and-true-p lsp-mode) (lsp-workspaces))
      (lsp-java-build-project)
    (let* ((file (buffer-file-name))
           (root (or (my/java--project-root)
                     (and file (file-name-directory file))
                     default-directory))
           (default-directory root))
      (compile (my/java--compile-command root file)))))

(defun my/java--run-standalone ()
  "Run the current file with the JDK's single-file source launcher."
  (let* ((file (buffer-file-name))
         (root (or (and file (file-name-directory file)) default-directory)))
    (unless file
      (user-error "Current buffer is not visiting a file"))
    (let ((default-directory root))
      (compile (format "%s -ea %s"
                       (shell-quote-argument (my/java-executable))
                       (shell-quote-argument file))))))

(defun my/java-run ()
  "Run the Java program in the current buffer.
For Maven/Gradle projects use the JDT launch configuration, which
resolves the classpath through the language server.  For standalone
files use the JDK's single-file source launcher."
  (interactive)
  (let ((root (my/java--project-root)))
    (if (and root (my/java--build-tool root))
        (call-interactively #'dap-java-debug)
      (my/java--run-standalone))))

(defun my/java-debug ()
  "Debug the Java program in the current buffer using JDT LS."
  (interactive)
  (unless (and (bound-and-true-p lsp-mode) (lsp-workspaces))
    (user-error "JDT LS is not running; open a Java file in a project first"))
  (call-interactively #'dap-java-debug))

(defun my/java-dependencies ()
  "Show the project's Java dependency tree via lsp-treemacs."
  (interactive)
  (require 'lsp-treemacs)
  (cond
   ((fboundp 'lsp-java-dependency-list)
    (call-interactively #'lsp-java-dependency-list))
   ((fboundp 'lsp-treemacs-java-deps-list)
    (call-interactively #'lsp-treemacs-java-deps-list))
   (t (user-error "No Java dependency view found in lsp-java/lsp-treemacs"))))

;;; Keymap --------------------------------------------------------------------

(defvar-keymap my/java-map
  :doc "Java IDE commands (C-c j)."
  "b" #'lsp-java-build-project
  "c" #'my/java-compile
  "r" #'my/java-run
  "d" #'my/java-debug
  "t" #'dap-java-run-test-method
  "T" #'dap-java-debug-test-method
  "f" #'lsp-format-buffer
  "i" #'lsp-java-organize-imports
  "a" #'lsp-execute-code-action
  "R" #'lsp-rename
  "p" #'lsp-java-update-project-configuration
  "g" #'lsp-java-generate-getters-and-setters
  "o" #'lsp-java-generate-overrides
  "s" #'lsp-java-generate-to-string
  "e" #'lsp-java-generate-equals-and-hash-code
  "v" #'lsp-java-open-super-implementation
  "h" #'lsp-describe-thing-at-point
  "n" #'my/java-dependencies)

(keymap-global-set "C-c j" my/java-map)

(provide 'init-java)
;;; init-java.el ends here
