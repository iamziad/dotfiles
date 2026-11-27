;; -*- lexical-binding: t; -*-

(let ((dir (expand-file-name "themes" user-emacs-directory)))
  (add-to-list 'load-path dir)
  (add-to-list 'custom-theme-load-path dir))

(require 'doom-themes)
(load-theme 'doom-gruvbox t)

(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))

(setq package-enable-at-startup nil
      frame-inhibit-implied-resize t
      inhibit-startup-screen t)

(dolist (setting '((menu-bar-lines . 0)
                   (tool-bar-lines . 0)
                   (vertical-scroll-bars . nil)
                   (left-fringe . 8)
                   (right-fringe . 0)))
  (add-to-list 'default-frame-alist setting))
