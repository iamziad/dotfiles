;; -*- lexical-binding: t; -*-

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      json-ts-mode-indent-offset 2)

(use-package add-node-modules-path
  :hook ((js-mode js-jsx-mode js-ts-mode
                  typescript-ts-mode tsx-ts-mode
                  json-ts-mode) . add-node-modules-path))

;;; fnm
(setenv "PATH" (concat (getenv "HOME") "/.local/share/fnm/aliases/default/bin:" (getenv "PATH")))
(setq exec-path (append exec-path (list (concat (getenv "HOME") "/.local/share/fnm/aliases/default/bin"))))

(use-package js
  :straight nil
  :mode (("\\.[cm]js\\'" . js-ts-mode)
         ("\\.jsx\\'" . js-ts-mode))
  :hook (js-ts-mode . lsp))

(use-package typescript-ts-mode
  :straight nil
  :mode (("\\.ts\\'"  . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode))
  :hook (typescript-ts-mode . lsp))

(use-package json-ts-mode
  :straight nil
  :mode (("\\.ts\\'"  . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode))
  :hook (json-ts-mode . lsp))

;; Chain eslint
(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-diagnostics-mode-hook
            (lambda ()
              (flycheck-add-next-checker 'lsp '(t . javascript-eslint)))))

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

(provide 'init-javascript)
