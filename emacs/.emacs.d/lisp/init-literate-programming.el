;; -*- lexical-binding: t; -*-

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (C . t) (shell . t) (java . t) (js . t) (sql . t)))
  (keymap-unset org-mode-map "C-c C-k")
  (require 'org-tempo))

(use-package verb
  :config
  (setq verb-json-use-mode 'json-ts-mode)
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c C-r") verb-command-map))
  (define-key verb-response-body-mode-map (kbd "q")
              (lambda () (interactive) (quit-window t))))

(provide 'init-literate-programming)
