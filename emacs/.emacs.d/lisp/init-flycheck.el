;; -*- lexical-binding: t; -*-

(use-package flycheck
  :ensure t
  :hook ((prog-mode . flycheck-mode)
         (yaml-mode . flycheck-mode))
  :custom
  ;; (flycheck-eglot-exclusive nil)
  (flycheck-keymap-prefix (kbd "C-c C-d"))
  (flycheck-annotate-current-line-style 'eol)
  :config
  ;; (global-flycheck-annotate-mode 1)
  ;; (global-flycheck-eglot-mode 1)
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)
        flycheck-highlighting-mode 'symbols)
  (dolist (face '(flycheck-annotate-error
                  flycheck-annotate-warning
                  flycheck-annotate-info))
    (set-face-attribute face nil :height 0.9))
  :bind
  (("C-c C-d a" . global-flycheck-annotate-mode)))

(with-eval-after-load 'flycheck
  (set-face-attribute 'flycheck-error nil :background 'unspecified)
  (set-face-attribute 'flycheck-warning nil :background 'unspecified)
  (set-face-attribute 'flycheck-info nil :background 'unspecified))

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
                (when-let* ((window (get-buffer-window "*Flycheck errors*")))
                  (select-window window)))))

(provide 'init-flycheck)
