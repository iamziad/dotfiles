;; -*- lexical-binding: t; -*-

(require 'project)
(require 'json)
(require 'seq)

;;;; Project.el ------------------------------------------------------------------

(use-package project
  :ensure nil

  :custom
  (project-vc-extra-root-markers
   '("package.json"
     ".project"
     "pom.xml"
     "build.gradle"
     "build.gradle.kts"
     "gradlew"
     "go.mod"
     "Cargo.toml"
     "pyproject.toml"
     "Makefile"
     "makefile"
     "GNUmakefile"
     "CMakeLists.txt"
     "deno.json"
     "composer.json"
     "Taskfile.yml"))

  :bind
  (:map project-prefix-map
        ("t n" . my/project-run-node-task)
        ("t m" . my/project-run-make-task)
        ("T"   . my/project-run-task))

  :config

  (add-to-list 'project-switch-commands
               '(my/project-run-task "Run task" ?T)
               t)

  (add-to-list 'project-switch-commands
               '(my/project-open-ghostel "Ghostel" ?m)
               t)
  )

;;;; Utilities ------------------------------------------------------------------

(defun my/project-run-compile (buffer-label command root)
  "Run COMMAND via `compile', naming the buffer using BUFFER-LABEL.
ROOT is used as `default-directory'."
  (let ((default-directory root)
        (compilation-buffer-name-function
         (lambda (_mode)
           (format "*project-task: %s*" buffer-label))))
    (compile command)))


(add-to-list 'display-buffer-alist
             '("\\*project-task: .*\\*"
               (display-buffer-reuse-window display-buffer-at-bottom)
               (window-height . 0.45)))


(defun my/project--sort-tasks (tasks)
  "Sort TASKS, an alist of (NAME . COMMAND), alphabetically by NAME."
  (sort tasks (lambda (a b) (string-lessp (car a) (car b)))))


;;;; Node.js tasks ---------------------------------------------------------------

(defconst my/project--lockfile-managers
  '(("pnpm" . "pnpm-lock.yaml")
    ("yarn" . "yarn.lock")
    ("bun"  . "bun.lock")
    ("bun"  . "bun.lockb"))
  "Alist of (MANAGER . LOCKFILE) used to detect the Node package manager.")


(defun my/project--detect-package-manager (package root)
  "Determine which Node package manager to use for PACKAGE at ROOT."
  (let ((package-manager (gethash "packageManager" package)))
    (or
     (and (stringp package-manager)
          (if (string-match "\\`\\([^@]+\\)@" package-manager)
              (match-string 1 package-manager)
            package-manager))

     (car (seq-find
           (lambda (pm) (file-exists-p (expand-file-name (cdr pm) root)))
           my/project--lockfile-managers))

     "npm")))


(defun my/project-node-tasks (&optional root)
  "Discover Node.js scripts from the project's package.json."
  (let* ((root (or root (project-root (project-current t))))
         (package-file (expand-file-name "package.json" root)))

    (when (file-readable-p package-file)
      (let* ((package
              (with-temp-buffer
                (insert-file-contents package-file)
                (json-parse-buffer :object-type 'hash-table)))

             (scripts (gethash "scripts" package))
             (manager (my/project--detect-package-manager package root))
             tasks)

        (when (hash-table-p scripts)
          (maphash
           (lambda (name _script)
             (push
              (cons
               (format "%s:%s" manager name)
               (format "%s run %s"
                       manager
                       (shell-quote-argument name)))
              tasks))
           scripts)

          (my/project--sort-tasks tasks))))))


(defun my/project-run-node-task ()
  "Select and run a Node.js script in the current project."
  (interactive)

  (let* ((root (project-root (project-current t)))
         (tasks (my/project-node-tasks root)))

    (unless tasks
      (user-error "No Node.js scripts found in package.json"))

    (let* ((task-name
            (completing-read
             "Run Node script: "
             (mapcar #'car tasks)
             nil t))

           (command (cdr (assoc task-name tasks))))

      (my/project-run-compile task-name command root))))


;;;; Makefile tasks --------------------------------------------------------------

(defun my/project-make-tasks (&optional root)
  "Discover Makefile targets from the project's Makefile."
  (let* ((root (or root (project-root (project-current t))))
         (makefile
          (seq-find #'file-readable-p
                    (mapcar
                     (lambda (f)
                       (expand-file-name f root))
                     '("Makefile" "makefile" "GNUmakefile")))))

    (when makefile
      (with-temp-buffer
        (insert-file-contents makefile)

        (let (tasks)
          (goto-char (point-min))

          (while
              (re-search-forward
               "^\\([A-Za-z0-9_.-]+\\)[ \t]*:\\(?:[^=]\\|$\\)"
               nil t)

            (let ((target (match-string 1)))
              (unless (or (string-prefix-p "." target)
                          (assoc target tasks))

                (push
                 (cons target
                       (format "make %s"
                               (shell-quote-argument target)))
                 tasks))))

          (my/project--sort-tasks tasks))))))


(defun my/project-run-make-task ()
  "Select and run a Makefile target in the current project."
  (interactive)

  (let* ((root (project-root (project-current t)))
         (tasks (my/project-make-tasks root)))

    (unless tasks
      (user-error "No Makefile targets found"))

    (let* ((task-name
            (completing-read
             "Run Make target: "
             (mapcar #'car tasks)
             nil t))

           (command (cdr (assoc task-name tasks))))

      (my/project-run-compile task-name command root))))


;;;; Unified project tasks -------------------------------------------------------

(defun my/project-tasks (&optional root)
  "Collect all supported tasks from the current project."
  (let* ((root (or root (project-root (project-current t))))

         (node-tasks
          (my/project-node-tasks root))

         (make-tasks
          (mapcar
           (lambda (task)
             (cons (format "make:%s" (car task))
                   (cdr task)))
           (my/project-make-tasks root)))

         (tasks (append node-tasks make-tasks)))

    (my/project--sort-tasks tasks)))


(defun my/project-run-task ()
  "Select and run a task from the current project."
  (interactive)

  (let* ((root (project-root (project-current t)))
         (tasks (my/project-tasks root)))

    (unless tasks
      (user-error "No supported tasks found in this project"))

    (let* ((task-name
            (completing-read
             "Run project task: "
             (mapcar #'car tasks)
             nil t))

           (command (cdr (assoc task-name tasks))))

      (my/project-run-compile task-name command root))))


;;;; Ghostel ---------------------------------------------------------------------

(defun my/project-open-ghostel ()
  "Open Ghostel in the current project."
  (interactive)

  (unless (or (fboundp 'ghostel-project)
              (require 'ghostel-project nil t))
    (user-error "Ghostel project integration is not installed"))

  (unless (fboundp 'ghostel-project)
    (user-error "Ghostel project command is unavailable"))

  (call-interactively #'ghostel-project))

(provide 'init-project)

;;; init-project.el ends here
