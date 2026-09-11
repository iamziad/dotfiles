;;; mod-compile.el -*- lexical-binding: t; -*-

(use-package compile
  :ensure nil
  :custom
  (compilation-always-kill t)
  (compilation-ask-about-save nil)
  (compilation-max-output-line-length nil)
  (compilation-scroll-output 'first-error)
  :config
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

  (autoload 'comint-truncate-buffer "comint" nil t)
  (defvar my/compile-buffer-max-size (* 80 comint-buffer-maximum-size))
  (add-hook 'compilation-filter-hook
            (defun my/compile-truncate-buffer-h (&optional _string)
              (when (> (buffer-size) my/compile-buffer-max-size)
                (let ((gc-cons-threshold most-positive-fixnum))
                  (with-silent-modifications
                    (comint-truncate-buffer)))))))

(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . -2)
               (window-height . 0.3)))

(defun my/compile-autobury-h (buffer msg)
  (when (and (string-match-p "^finished" msg)
             (not (eq (window-buffer (selected-window)) buffer)))
    (run-with-timer
     1 nil
     (lambda ()
       (when-let* ((win (get-buffer-window buffer)))
         (unless (eq win (selected-window))
           (quit-window nil win)))))))
(add-hook 'compilation-finish-functions #'my/compile-autobury-h)

(provide 'mod-compile)
