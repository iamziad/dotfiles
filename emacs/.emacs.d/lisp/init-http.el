;; -*- lexical-binding: t; -*-

(use-package verb
  :ensure t
  :config
  (setq verb-json-use-mode 'json-ts-mode)
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c C-r") verb-command-map))
  (define-key verb-response-body-mode-map (kbd "q")
              (lambda () (interactive) (quit-window t))))

(provide 'init-http)
