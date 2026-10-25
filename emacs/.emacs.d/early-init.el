;; -*- lexical-binding: t; -*-

;;; Performance

;; Postpone garbage collection while the rest of the configuration is loaded.
;; `my/restore-startup-settings' below puts it back to a sane value.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; File name handlers (TRAMP, archive handlers, ...) are expensive during
;; startup and are not needed until Emacs is fully initialized.
(defvar my/early-init-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun my/restore-startup-settings ()
  "Restore settings that are temporarily relaxed during startup."
  (setq gc-cons-threshold (* 32 1024 1024)
        gc-cons-percentage 0.1
        file-name-handler-alist my/early-init-file-name-handler-alist))

(add-hook 'emacs-startup-hook #'my/restore-startup-settings)

;;; Package management

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(setq package-native-compile t
      ;; Keep built-in packages as shipped with Emacs unless explicitly
      ;; upgraded; this keeps the configuration stable across Emacs updates.
      package-install-upgrade-built-in nil)

;;; Frames and startup UI

(setq inhibit-startup-screen t
      initial-scratch-message nil
      initial-buffer-choice nil
      frame-inhibit-implied-resize t
      use-dialog-box nil
      use-file-dialog nil
      native-comp-async-report-warnings-errors 'silent)

(push '(background-color . "#282828") default-frame-alist)
(push '(foreground-color . "#ebdbb2") default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)
(push '(left-fringe . 8) default-frame-alist)
(push '(right-fringe . 0) default-frame-alist)

(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode) (tooltip-mode -1))

(provide 'early-init)
