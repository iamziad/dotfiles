;;; mod-olivetti.el --- Centered, distraction-free writing -*- lexical-binding: t; -*-

(use-package olivetti
  :hook ((eww-mode . olivetti-mode)
         (olivetti-mode . mod-olivetti--toggle))
  :bind ("C-c v o" . olivetti-mode)
  :custom (olivetti-body-width 90))

(defvar-local mod-olivetti--state nil)

(defun mod-olivetti--apply-fringes (&rest _)
  (when olivetti-mode
    (dolist (win (get-buffer-window-list (current-buffer) nil t))
      (set-window-fringes win 0 0 nil t))))

(defun mod-olivetti--toggle ()
  (if olivetti-mode
      (progn
        (setq mod-olivetti--state
              (list (bound-and-true-p display-line-numbers-mode)
                    (bound-and-true-p display-fill-column-indicator-mode)
                    cursor-type))
        (display-line-numbers-mode -1)
        (display-fill-column-indicator-mode -1)
        (setq-local cursor-type 'bar)
        (mod-olivetti--apply-fringes)
        (add-hook 'window-configuration-change-hook #'mod-olivetti--apply-fringes nil t))
    (cl-destructuring-bind (ln fci ct) mod-olivetti--state
      (when ln (display-line-numbers-mode 1))
      (when fci (display-fill-column-indicator-mode 1))
      (setq-local cursor-type ct)
      (remove-hook 'window-configuration-change-hook #'mod-olivetti--apply-fringes t)
      (dolist (win (get-buffer-window-list (current-buffer) nil t))
        (set-window-fringes win nil nil nil nil)))))

(provide 'mod-olivetti)
;;; mod-olivetti.el ends here
