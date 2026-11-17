;;; init-compile.el --- Compilation buffers -*- lexical-binding: t; -*-

(require 'ansi-color)

(defun my/colorize-compilation-buffer ()
  "Apply ANSI colour codes in the current compilation buffer."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region compilation-filter-start (point))))

(use-package compile
  :ensure nil
  :custom
  (compilation-always-kill t)
  (compilation-ask-about-save nil)
  (compilation-max-output-line-length nil)
  (compilation-scroll-output 'first-error)
  :init
  (add-to-list 'display-buffer-alist
               '((derived-mode . compilation-mode)
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (window-height . 0.45)))
  :config
  (add-hook 'compilation-filter-hook #'my/colorize-compilation-buffer))

(keymap-global-set "C-c c" #'compile)
(keymap-global-set "C-c C" #'recompile)

(provide 'init-compile)
;;; init-compile.el ends here
