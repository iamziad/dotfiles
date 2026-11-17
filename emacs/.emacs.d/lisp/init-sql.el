;;; init-sql.el --- SQL configuration -*- lexical-binding: t; -*-

(use-package sqlite-mode
  :ensure nil
  :defer t
  :config
  (add-to-list 'display-buffer-alist
               '("\\*SQLITE .*\\*"
                 (display-buffer-reuse-window
                  display-buffer-below-selected)
                 (window-height . 0.45)))
  (keymap-set sqlite-mode-map "n" #'next-line)
  (keymap-set sqlite-mode-map "p" #'previous-line))

(use-package sql-indent
  :ensure t
  :hook (sql-mode . sqlind-minor-mode))

(use-package sqlup-mode
  :ensure t
  :hook ((sql-mode . sqlup-mode)
         (sql-interactive-mode . sqlup-mode)))

(with-eval-after-load 'sql
  (setq sql-input-ring-file-name
        (locate-user-emacs-file ".sqli_history"))
  (add-to-list 'sql-postgres-options "--no-psqlrc"))

(use-package sqlformat
  :ensure t
  :after sql
  :config
  (keymap-set sql-mode-map "C-c C-q f" #'sqlformat))

(provide 'init-sql)
;;; init-sql.el ends here
