;; -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

(setq gc-cons-threshold (* 128 1024 1024)
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1)))

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      initial-buffer-choice nil
      frame-inhibit-implied-resize t
      inhibit-compacting-font-caches t)

(push '(background-color . "#282828") default-frame-alist)
(push '(foreground-color . "#ebdbb2") default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)
(push '(left-fringe . 8) default-frame-alist)
(push '(right-fringe . 0) default-frame-alist)

(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

(setq-default bidi-paragraph-direction 'left-to-right)

(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist
                  my/file-name-handler-alist)))
