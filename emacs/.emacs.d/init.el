;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

(setq user-full-name "Ziad Ahmed"
      user-mail-address "dev.ziadahmed@gmail.com")

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t t)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-defaults)
(require 'init-keybindings)
(require 'init-ui)
(require 'init-tabs)
(require 'init-completion)
(require 'init-consult)
(require 'init-dired)
(require 'init-org)
(require 'init-anki)
(require 'init-eww)
(require 'init-eshell)
(require 'init-ghostel)
(require 'init-project)
(require 'init-jinx)
(require 'init-qof)
(require 'init-git)
(require 'init-ai)
(require 'init-treesitter)
(require 'init-flycheck)
(require 'init-prog)
(require 'init-http)
(require 'init-markdown)
(require 'init-lsp)
(require 'init-lsp-booster)
(require 'init-treemacs)
(require 'init-zen-mode)

(require 'init-c)
(require 'init-java)
(require 'init-javascript)
(require 'init-sql)
;;(require 'init-web)

;;; init.el ends here
