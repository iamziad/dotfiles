;;; lang-sql.el --- SQL configuration -*- lexical-binding: t; -*-

(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode))

(use-package sqlup-mode
  :hook ((sql-mode . sqlup-mode)
         (sql-interactive-mode . sqlup-mode)))

(with-eval-after-load 'sql
  (sql-input-ring-file-name (locate-user-emacs-file ".sqli_history"))
  (add-to-list 'sql-postgres-options "--no-psqlrc"))

  ;; Apply SQL syntax highlighting in SQLi buffers.
  (defun my/sql-interactive-font-lock ()
    "Apply product-specific SQL highlighting in SQLi."
    (unless (eq sql-product 'oracle)
      (sql-product-font-lock nil nil)))

  (add-hook 'sql-interactive-mode-hook
            #'my/sql-interactive-font-lock)

  ;; Switch to the corresponding SQLi buffer.
  (defun my/sql-pop-to-sqli-buffer ()
    "Switch to the corresponding SQLi buffer."
    (interactive)
    (if (and (boundp 'sql-buffer)
             (buffer-live-p sql-buffer))
        (pop-to-buffer sql-buffer)
      (sql-set-sqli-buffer)
      (when (and (boundp 'sql-buffer)
                 (buffer-live-p sql-buffer))
        (pop-to-buffer sql-buffer)))
    (when (and (boundp 'sql-buffer)
               (buffer-live-p sql-buffer))
      (with-current-buffer sql-buffer
        (goto-char (point-max))))

  ;; SQL editing keybindings.
  (define-key sql-mode-map
              (kbd "C-c C-q p")
              #'my/sql-pop-to-sqli-buffer))

;; SQL formatting
(use-package sqlformat
  :ensure t
  :after sql
  :bind (:map sql-mode-map
         ("C-c C-q f" . sqlformat)))

;; Optional: PostgreSQL documentation through Dash.
(use-package dash-at-point
  :ensure t
  :after sql
  :hook ((sql-mode . my/sql-set-postgres-docset)
         (sql-interactive-mode . my/sql-set-postgres-docset))
  :config
  (defun my/sql-set-postgres-docset ()
    "Use the PostgreSQL docset for PostgreSQL buffers."
    (when (eq sql-product 'postgres)
      (setq-local dash-at-point-docset "psql")))

  (advice-add 'sql-set-product
              :after #'my/sql-set-postgres-docset))

(provide 'lang-sql)
;;; lang-sql.el ends here
