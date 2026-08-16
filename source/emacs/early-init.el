;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; --- Startup performance -------------------------------------------------
(setq gc-cons-threshold (* 64 1024 1024)
      gc-cons-percentage 0.6
      read-process-output-max (* 1024 1024)) ; 1mb, helps lsp-mode throughput

(defvar my/file-name-handler-alist-backup file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist my/file-name-handler-alist-backup)))

(setq inhibit-compact-font-caches t)
(setq-default bidi-inhibit-bpa t)

;; --- Package system --------------------------------------------------------
(setq package-enable-at-startup nil)

;; --- UI: avoid a flash of unstyled frame ----------------------------------
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

;; LSP performance improvements
(setenv "LSP_USE_PLISTS" "true")

;;; early-init.el ends here
