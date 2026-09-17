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
               (window-height . 0.4)))

;; خلي الفوكس ينتقل للـ compile window لما يظهر
(advice-add 'compilation-start :after
            (defun my/compile-select-window-a (&rest _)
              (when-let* ((win (get-buffer-window "*compilation*" t)))
                (select-window win))))

(with-eval-after-load 'compile
  (add-to-list 'compilation-error-regexp-alist 'node)
  (add-to-list 'compilation-error-regexp-alist-alist
               '(node "^[[:blank:]]*at \\(.*(\\|\\)\\(.+?\\):\\([[:digit:]]+\\):\\([[:digit:]]+\\)"
                      2 3 4)))


(provide 'mod-compile)
