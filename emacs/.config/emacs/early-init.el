;;; early-init.el -*- lexical-binding: t -*-

;;;; Package

;; straight.el manages packages; let package.el stay out of the way.
(setq package-enable-at-startup nil)

;;;; Garbage collection

;; Raise the GC threshold while Emacs starts up, then restore it.
(setq gc-cons-threshold (* 128 1024 1024)
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1)))

;;;; Startup UI

;; Keep the initial frame quiet: no chrome and no flashing white frame.
(setq inhibit-startup-screen t
      initial-scratch-message nil
      inhibit-startup-echo-area-message user-login-name)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(cursor-type . box) default-frame-alist)
(push '(cursor-in-non-selected-windows . nil) default-frame-alist)

;; Pixelwise resizing from the very first frame.
(push '(left-fringe . 0) default-frame-alist)
(push '(right-fringe . 0) default-frame-alist)

(when (eq system-type 'gnu/linux)
  (setq x-gtk-use-system-tooltips nil))

;;;; Process performance

;; Subprocesses inherit more headroom and don't slow down Emacs.
(setq read-process-output-max (* 1024 1024))

(setq process-adaptive-read-buffering nil)

(provide 'early-init)
;;; early-init.el ends here
