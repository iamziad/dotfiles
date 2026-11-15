;; -*- lexical-binding: t; -*-

;;; Customization

(use-package compile
  :ensure nil
  :custom
  (compilation-scroll-output 'first-error)
  (compilation-read-command nil)
  (compilation-ask-about-save nil)
  (compilation-save-buffers-predicate (lambda () nil))
  (compilation-always-kill t)
  (compilation-window-height 15)
  :config
  (require 'ansi-color)
  (defun my/colorize-compilation-buffer ()
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region compilation-filter-start (point))))
  (add-hook 'compilation-filter-hook #'my/colorize-compilation-buffer))

(provide 'init-compile)
;;; init-compile.el ends here
