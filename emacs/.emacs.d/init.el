;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

(setq user-full-name "Ziad Ahmed"
      user-mail-address "dev.ziadahmed@gmail.com")

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t t)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-elpaca)
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
(require 'init-compile)
(require 'init-jinx)
(require 'init-qof)
(require 'init-git)
(require 'init-ai)
(require 'init-flymake)
(require 'init-prog)
(require 'init-http)
(require 'init-markdown)
(require 'init-eglot)
(require 'init-zen-mode)

(require 'init-c)
(require 'init-java)
(require 'init-javascript)
(require 'init-sql)
(require 'init-web)

;;; Abandoned
;; (require 'init-treesitter)
;; (require 'init-flycheck)
;; (require 'init-lsp)
;; (require 'init-lsp-booster)
;; (require 'init-treemacs)

;;; init.el ends here
