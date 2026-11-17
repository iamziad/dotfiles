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
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

(provide 'init-js)
