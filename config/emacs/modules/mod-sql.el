;;; mod-sql.el --- SQL Related -*- lexical-binding: t; -*-

(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode))

(use-package sqlup-mode
  :hook ((sql-mode . sqlup-mode)
         (sql-interactive-mode . sqlup-mode)))

;; (use-package sqlformat
;;   :ensure nil
;;   :commands (sqlformat sqlformat-buffer sqlformat-region)
;;   :hook (sql-mode . sqlformat-on-save-mode)
;;   :init
;;   (setq sqlformat-command 'pgformatter
;;         sqlformat-args '("-s2" "-g" "-u2")))

;;
(defun my/sql-send-buffer-to (target)
  "Send current buffer's SQL to TARGET SQLi buffer."
  (interactive
   (list (read-buffer "Send to SQLi: " nil t
                      (lambda (b)
                        (with-current-buffer (if (consp b) (cdr b) b)
                          (derived-mode-p 'sql-interactive-mode))))))
  (let ((sql-buffer (get-buffer target)))
    (sql-send-buffer)))

(global-set-key (kbd "C-c C-a") #'my/sql-send-buffer-to)

;;

(setq sql-postgres-login-params
      '((user :default "postgres")
        (database :default "postgres")
        (server :default "localhost")
        (port :default 5432)))

(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (toggle-truncate-lines t)))

;; --- Frequent Connections ---

(setq sql-connection-alist
      '((postgres
         (sql-product 'postgres)
         (sql-server "127.0.0.1")
         (sql-user "postgres")
         (sql-password "")
         (sql-database "postgres")
         (sql-port 5432))
        (MyDatabase
         (sql-product 'postgres)
         (sql-server "127.0.0.1")
         (sql-user "postgres")
         (sql-password "")
         (sql-database "MyDatabase")
         (sql-port 5432))
        (salesdb
         (sql-product 'postgres)
         (sql-server "127.0.0.1")
         (sql-user "postgres")
         (sql-password "")
         (sql-database "salesdb")
         (sql-port 5432))))

;; --- LSP ---

(setq lsp-sqls-connections
      '(((driver . "postgresql")
         (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=postgres sslmode=disable"))
        ((driver . "postgresql")
         (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=MyDatabase sslmode=disable"))
        ((driver . "postgresql")
         (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=salesdb sslmode=disable"))))

(provide 'mod-sql)

;;; mod-sql.el ends here
