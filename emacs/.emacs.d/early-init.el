;; -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1024 1024)
                  gc-cons-percentage 0.1)))

(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist my/file-name-handler-alist)))

(setq package-enable-at-startup nil)

(setq frame-inhibit-implied-resize t)

;; (push '(background-color . "#282828") default-frame-alist)
;; (push '(foreground-color . "#ebdbb2") default-frame-alist)

(setq inhibit-compacting-font-caches t)
(setq-default inhibit-redisplay t)
(add-hook 'post-command-hook
          (lambda () (setq-default inhibit-redisplay nil)) nil nil)

(when (boundp 'native-comp-async-report-warnings-errors)
  (setq native-comp-async-report-warnings-errors 'silent))

(setq inhibit-startup-screen t)

(setenv "LSP_USE_PLISTS" "true")
