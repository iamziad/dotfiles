;;; early-init.el -*- lexical-binding: t; -*-

(setq gc-cons-percentage 1.0
      gc-cons-threshold most-positive-fixnum)

(setq read-process-output-max (* 64 1024))

(defvar my/file-name-handler-alist-backup file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist my/file-name-handler-alist-backup)))

(setq inhibit-compact-font-caches t)
(setq-default bidi-inhibit-bpa t)

(setq auto-mode-case-fold nil)

(setq ad-redefinition-action 'accept)

(unless init-file-debug
  (setq native-comp-async-report-warnings-errors nil
        native-comp-warning-on-missing-source nil))

(setq package-enable-at-startup nil)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq fast-but-imprecise-scrolling t
      frame-inhibit-implied-resize t
      frame-resize-pixelwise t
      idle-update-delay 1.0
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil)

(setenv "LSP_USE_PLISTS" "true")
