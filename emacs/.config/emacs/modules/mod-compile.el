;;; mod-compile.el -*- lexical-binding: t; -*-

(use-package compile
  :ensure nil
  :custom
  (compilation-always-kill t)
  (compilation-ask-about-save nil)
  (compilation-max-output-line-length nil)
  (compilation-scroll-output 'first-error)
  ;; (display-buffer-alist
  ;;  '(("\\*compilation\\*" (display-buffer-reuse-window display-buffer-in-side-window)
  ;;     (side . bottom) (slot . -2) (window-height . 0.45))))
  :hook ((prog-mode . my/guess-compile-command)
         (compilation-filter . ansi-color-compilation-filter))
  :init
  (advice-add 'compilation-start :after
              (lambda (&rest _)
                (when-let ((w (get-buffer-window "*compilation*")))
                  (select-window w)))))

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
