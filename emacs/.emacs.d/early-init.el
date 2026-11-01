;; -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(defvar my/early-init-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun my/restore-startup-settings ()
  (setq gc-cons-threshold (* 100 1024 1024)
        gc-cons-percentage 0.1
        file-name-handler-alist
        (delete-dups (append file-name-handler-alist
                             my/early-init-file-name-handler-alist))))

(add-hook 'emacs-startup-hook #'my/restore-startup-settings 101)

(setq package-native-compile t
      package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities '(("melpa" . 10)
                                   ("nongnu" . 5)
                                   ("gnu" . 0)))

(setq inhibit-startup-screen t
      initial-scratch-message nil
      initial-buffer-choice nil
      frame-inhibit-implied-resize t
      use-dialog-box nil
      use-file-dialog nil
      inhibit-compacting-font-caches t
      native-comp-async-report-warnings-errors 'silent)

;; (push '(background-color . "#282828") default-frame-alist)
;; (push '(foreground-color . "#ebdbb2") default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)
(push '(left-fringe . 8) default-frame-alist)
(push '(right-fringe . 0) default-frame-alist)

(when (fboundp 'tooltip-mode) (tooltip-mode -1))

(setenv "LSP_USE_PLISTS" "true")
