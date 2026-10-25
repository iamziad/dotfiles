;;;; SQL / PostgreSQL  -*- lexical-binding: t; -*-

(use-package pgsql)

(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode)
  :diminish sqlind-minor-mode)

(use-package sqlup-mode
  :hook ((sql-mode . sqlup-mode)
         (sql-interactive-mode . sqlup-mode))
  :diminish sqlup-mode)

;; (use-package sqlformat
;;   :straight nil
;;   :commands (sqlformat sqlformat-buffer sqlformat-region)
;;   :hook (sql-mode . sqlformat-on-save-mode)
;;   :init
;;   (setq sqlformat-command 'pgformatter
;;         sqlformat-args '("-s2" "-g" "-u2")))

(defun my/sql-truncate-lines ()
  "Don't wrap long result rows in SQLi buffers."
  (toggle-truncate-lines t))

(use-package sql
  :straight nil
  :custom
  (sql-postgres-login-params
   '((user :default "postgres")
     (database :default "postgres")
     (server :default "localhost")
     (port :default 5432)))
  :hook (sql-interactive-mode . my/sql-truncate-lines))

(defvar sql-buffer)

(defun my/sql-send-buffer-to (target)
  "Send the current buffer's SQL to the SQLi buffer TARGET."
  (interactive
   (list (read-buffer "Send to SQLi: " nil t
                      (lambda (b)
                        (with-current-buffer (if (consp b) (cdr b) b)
                          (derived-mode-p 'sql-interactive-mode))))))
  (let ((sql-buffer (get-buffer target)))
    (sql-send-buffer)))

(keymap-global-set "C-c C-a" #'my/sql-send-buffer-to)

(provide 'sql)
