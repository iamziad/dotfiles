;;; early-init.el -*- lexical-binding: t -*-

(setq package-enable-at-startup nil)

(setq gc-cons-threshold (* 128 1024 1024)
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1)))

(setq inhibit-startup-screen t
      initial-scratch-message nil
      inhibit-startup-echo-area-message user-login-name)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(cursor-type . box) default-frame-alist)
(push '(cursor-in-non-selected-windows . nil) default-frame-alist)

(let ((frame-params '((background-color . "#282828")
                      (foreground-color . "#ebdbb2"))))
  (setq default-frame-alist
        (append frame-params default-frame-alist))
  (setq initial-frame-alist
        (append frame-params initial-frame-alist)))

(push '(left-fringe . 8) default-frame-alist)
(push '(right-fringe . 8) default-frame-alist)

(when (eq system-type 'gnu/linux)
  (setq x-gtk-use-system-tooltips nil))

(setq read-process-output-max (* 1024 1024))

(setq process-adaptive-read-buffering nil)

(provide 'early-init)
;;; early-init.el ends here
