;;; mod-literate-programming.el --- org babel settings -*- lexical-binding: t; -*-

(setq org-confirm-babel-evaluate nil
      python-shell-completion-native-enable nil
      org-src-window-setup 'current-window)

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (C . t) (shell . t) (java . t) (js . t) (sql . t))))

(use-package verb
  :config
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c C-r") verb-command-map))
  (define-key verb-response-body-mode-map (kbd "q")
              (lambda ()
                (interactive)
                (quit-window t))))

(provide 'mod-literate-programming)
;;; mod-literate-programming.el ends here
