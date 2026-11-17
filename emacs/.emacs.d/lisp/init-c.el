;;;; C and Makefiles  -*- lexical-binding: t; -*-

(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "k&r")))

(defun my/makefile-mode-setup ()
  "Use tabs for indentation in Makefiles."
  (setq-local indent-tabs-mode t))

(add-hook 'makefile-mode-hook #'my/makefile-mode-setup)

(defun my/mark-function-body ()
  (interactive)
  (beginning-of-defun)
  (search-forward "{")
  (let ((start (point)))
    (backward-char)
    (forward-sexp)
    (backward-char)
    (push-mark start nil t)
    (setq deactivate-mark nil)))

(with-eval-after-load 'cc-mode
  (define-key c-mode-base-map (kbd "C-c m b") #'my/mark-function-body))

(provide 'init-c)
