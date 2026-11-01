;; -*- lexical-binding: t; -*-

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/Projects/"))
  (projectile-mode 1)
  :config
  (setq projectile-globally-ignored-directories
  '(".git" ".hg" "node_modules" "bower_components" "dist" "build"
    "out" "target" ".angular" ".next" ".nuxt" ".cache" "coverage" "vendor"
    ".venv" "__pycache__" "tmp")
  projectile-globally-ignored-files '(".DS_Store" "TAGS" "*.pyc" "*.class"))

  (define-key projectile-mode-map (kbd "C-x C-b") 'projectile-ibuffer)
  :bind-keymap ("C-c p" . projectile-command-map))

(use-package hl-todo
  :init (global-hl-todo-mode 1))

(add-to-list 'display-buffer-alist
             '("\\*projectile-task: .*\\*"
               (display-buffer-reuse-window display-buffer-at-bottom)
               (window-height . 0.45)))

(provide 'init-projectile)
