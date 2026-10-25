;; -*- lexical-binding: t; -*-

(use-package projectile
  :init
  (setq projectile-project-search-path '("~/Projects/"))
  (projectile-mode 1)
  :config
  (define-key projectile-mode-map (kbd "C-x p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-x C-b") 'projectile-ibuffer))

(use-package hl-todo
  :init (global-hl-todo-mode 1))

(add-to-list 'display-buffer-alist
             '("\\*projectile-task: .*\\*"
               (display-buffer-reuse-window display-buffer-at-bottom)
               (window-height . 0.45)))


(provide 'init-projectile)
