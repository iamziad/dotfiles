;; -*- lexical-binding: t; -*-

(use-package flycheck
  :ensure t
  :hook ((prog-mode . flycheck-mode)
         (yaml-mode . flycheck-mode))
  :custom
  ;; (flycheck-eglot-exclusive nil)
  (flycheck-keymap-prefix (kbd "C-c 1"))
  (flycheck-annotate-current-line-style 'eol)
  :config
  ;; (global-flycheck-annotate-mode 1)
  ;; (global-flycheck-eglot-mode 1)
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)
        flycheck-idle-change-delay 1.0
        flycheck-display-errors-delay 0.3
        flycheck-highlighting-mode 'symbols
        flycheck-keymap-prefix (kbd "C-c !"))
  (dolist (face '(flycheck-annotate-error
                  flycheck-annotate-warning
                  flycheck-annotate-info))
    (set-face-attribute face nil :height 0.9))
  (dolist (face '(flycheck-error flycheck-warning flycheck-info))
    (set-face-attribute face nil :background 'unspecified))
  :bind
  (("C-c 1 a" . global-flycheck-annotate-mode)))

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
