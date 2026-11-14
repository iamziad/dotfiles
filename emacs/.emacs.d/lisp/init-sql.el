;;; init-sql.el --- SQL configuration -*- lexical-binding: t; -*-

(use-package sqlite-mode
  :straight nil
  :defer
  :config
  (add-to-list 'display-buffer-alist
               '("\\*SQLITE .*\\*"
                 (display-buffer-reuse-window
                  display-buffer-below-selected)
                 (window-height . 0.45)))
  :bind (:map sqlite-mode-map
              ("n" . next-line)
              ("p" . previous-line)))

(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode))

(use-package sqlup-mode
  :hook ((sql-mode . sqlup-mode)
         (sql-interactive-mode . sqlup-mode)))

(with-eval-after-load 'sql
  (setq sql-input-ring-file-name
        (locate-user-emacs-file ".sqli_history"))

  (add-to-list 'sql-postgres-options "--no-psqlrc"))

;; SQL formatting
(use-package sqlformat
  :ensure t
  :after sql
  :bind (:map sql-mode-map
              ("C-c C-q f" . sqlformat)))

(provide 'init-sql)
;;; init-sql.el ends here
