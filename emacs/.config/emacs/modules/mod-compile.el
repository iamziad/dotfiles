;;; mod-compile.el -*- lexical-binding: t; -*-

(use-package compile
  :ensure nil
  :custom
  (compilation-always-kill t)
  (compilation-ask-about-save nil)
  (compilation-max-output-line-length nil)
  (compilation-scroll-output 'first-error)
  (compilation-environment '("TERM=xterm-256color" "FORCE_COLOR=1"))
  :config
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
  (add-hook 'prog-mode-hook #'my/guess-compile-command)

  (autoload 'comint-truncate-buffer "comint" nil t)
  (defvar my/compile-buffer-max-size (* 80 comint-buffer-maximum-size))
  (add-hook 'compilation-filter-hook
            (defun my/compile-truncate-buffer-h (&optional _string)
              (when (> (buffer-size) my/compile-buffer-max-size)
                (let ((gc-cons-threshold most-positive-fixnum))
                  (with-silent-modifications
                    (comint-truncate-buffer)))))))

(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . -2)
               (window-height . 0.5)))

(advice-add 'compilation-start :after
            (defun my/compile-select-window-a (&rest _)
              (when-let* ((win (get-buffer-window "*compilation*" t)))
                (select-window win))))

(with-eval-after-load 'compile
  (add-to-list 'compilation-error-regexp-alist 'node)
  (add-to-list 'compilation-error-regexp-alist-alist
               '(node "^[[:blank:]]*at \\(.*(\\|\\)\\(.+?\\):\\([[:digit:]]+\\):\\([[:digit:]]+\\)"
                      2 3 4)))

(defun my/guess-compile-command ()
  "Set a buffer-local `compile-command' from the nearest build file."
  (unless (file-remote-p default-directory)
    (cl-flet ((has (f) (locate-dominating-file default-directory f)))
      (cond
       ((has "package.json")   (setq-local compile-command "npm run build"))
       ((has "pom.xml")        (setq-local compile-command "mvn -q compile"))
       ((or (has "build.gradle") (has "build.gradle.kts"))
        (setq-local compile-command "./gradlew build"))
       ((has "CMakeLists.txt") (setq-local compile-command "cmake --build build"))
       ((has "Makefile")       (setq-local compile-command "make -k"))
       ((and buffer-file-name (derived-mode-p 'c-mode 'c-ts-mode))
        (setq-local compile-command
                    (format "gcc -Wall -Wextra -g -o %s %s"
                            (shell-quote-argument (file-name-base buffer-file-name))
                            (shell-quote-argument
                             (file-name-nondirectory buffer-file-name)))))))))

(provide 'mod-compile)
