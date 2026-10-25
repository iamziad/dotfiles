;; -*- lexical-binding: t; -*-

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode +1)
  :custom
  (flycheck-keymap-prefix (kbd "C-c C-d"))
  (flycheck-annotate-current-line-style 'eol)
  :config
  (dolist (face '(flycheck-annotate-error
                  flycheck-annotate-warning
                  flycheck-annotate-info))
    (set-face-attribute face nil :height 0.9)))

(global-flycheck-annotate-mode)

(defvar-keymap my/flycheck-repeat-map
  :repeat t
  "n" #'flycheck-next-error
  "p" #'flycheck-previous-error
  "l" #'flycheck-list-errors)

(put 'flycheck-next-error 'repeat-map 'my/flycheck-repeat-map)
(put 'flycheck-previous-error 'repeat-map 'my/flycheck-repeat-map)
(put 'flycheck-list-errors 'repeat-map 'my/flycheck-repeat-map)

(with-eval-after-load 'flycheck
  (advice-add 'flycheck-list-errors :after
              (lambda (&rest _)
                (when-let ((window (get-buffer-window "*Flycheck errors*")))
                  (select-window window)))))

(provide 'init-flycheck)
