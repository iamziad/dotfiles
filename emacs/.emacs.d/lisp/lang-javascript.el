;; -*- lexical-binding: t; -*-

;;; Indentation
(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      json-ts-mode-indent-offset 2)

;;; Node.js (fnm)
(let ((node-bin (expand-file-name
                 "~/.local/share/fnm/aliases/default/bin")))
  (setenv "PATH" (concat node-bin path-separator (getenv "PATH")))
  (add-to-list 'exec-path node-bin))

;;; Treesitter & file associations
(add-to-list 'auto-mode-alist '("\\.[cm]js\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

;;; Tailwind detection
(defun my/tailwind-project-p ()
  "Check whether the current project uses Tailwind CSS."
  (locate-dominating-file
   default-directory
   (lambda (dir)
     (or (directory-files dir nil "\\`tailwind\\.config\\.")
         (file-directory-p
          (expand-file-name "node_modules/tailwindcss" dir)))))

;;; Server commands
  (defun my/frontend-js-server (&rest _)
    (append
     '("rass"
       "--" "typescript-language-server" "--stdio"
       "--" "vscode-eslint-language-server" "--stdio")
     (when (my/tailwind-project-p)
       '("--" "tailwindcss-language-server" "--stdio"))))

  (defun my/frontend-html-server (&rest _)
    (append
     '("rass" "--" "vscode-html-language-server" "--stdio")
     (when (my/tailwind-project-p)
       '("--" "tailwindcss-language-server" "--stdio"))))

  (defun my/frontend-css-server (&rest _)
    (append
     '("rass" "--" "vscode-css-language-server" "--stdio")
     (when (my/tailwind-project-p)
       '("--" "tailwindcss-language-server" "--stdio"))))

;;; Eglot server registrations
  (with-eval-after-load 'eglot
    (add-to-list
     'eglot-server-programs
     '(((js-ts-mode :language-id "javascript")
        (tsx-ts-mode :language-id "typescriptreact")
        (typescript-ts-mode :language-id "typescript"))
       . my/frontend-js-server))

    (add-to-list
     'eglot-server-programs
     '((html-ts-mode mhtml-mode)
       . my/frontend-html-server))

    (add-to-list
     'eglot-server-programs
     '((css-ts-mode)
       . my/frontend-css-server))

    (setq-default eglot-workspace-configuration
                  '(:css (:lint (:unknownAtRules "ignore")))))

  (provide 'lang-javascript)
