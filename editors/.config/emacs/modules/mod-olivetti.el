;;; mod-olivetti.el --- Centered, distraction-free writing -*- lexical-binding: t; -*-

(defvar-local mod-olivetti--line-numbers-was-on nil)
(defvar-local mod-olivetti--fci-was-on nil)
(defvar-local mod-olivetti--cursor-type-orig nil)

(defun mod-olivetti--apply-fringes (&rest _)
  "Force-hide fringes for every window showing this buffer, persistently."
  (when olivetti-mode
    (dolist (win (get-buffer-window-list (current-buffer) nil t))
      (set-window-fringes win 0 0 nil t))))

(defun mod-olivetti--enable ()
  (setq mod-olivetti--line-numbers-was-on (bound-and-true-p display-line-numbers-mode))
  (setq mod-olivetti--fci-was-on (bound-and-true-p display-fill-column-indicator-mode))
  (setq mod-olivetti--cursor-type-orig cursor-type)
  (when mod-olivetti--line-numbers-was-on
    (display-line-numbers-mode -1))
  (when mod-olivetti--fci-was-on
    (display-fill-column-indicator-mode -1))
  (setq-local cursor-type 'bar)
  (mod-olivetti--apply-fringes)
  (add-hook 'window-configuration-change-hook #'mod-olivetti--apply-fringes nil t))

(defun mod-olivetti--disable ()
  (when mod-olivetti--line-numbers-was-on
    (display-line-numbers-mode 1))
  (when mod-olivetti--fci-was-on
    (display-fill-column-indicator-mode 1))
  (setq-local cursor-type mod-olivetti--cursor-type-orig)
  (remove-hook 'window-configuration-change-hook #'mod-olivetti--apply-fringes t)
  (dolist (win (get-buffer-window-list (current-buffer) nil t))
    (set-window-fringes win nil nil nil nil)))

(defun mod-olivetti--sync ()
  (if olivetti-mode
      (mod-olivetti--enable)
    (mod-olivetti--disable)))

(use-package olivetti
  :hook (((eww-mode) . olivetti-mode)
         (olivetti-mode . mod-olivetti--sync))
  :custom
  (olivetti-body-width 90))

(provide 'mod-olivetti)
;;; mod-olivetti.el ends here
