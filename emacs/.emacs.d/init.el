;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

(setq user-full-name "Ziad Ahmed"
      user-mail-address "dev.ziadahmed@gmail.com")

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t t)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(let ((default-directory
       (expand-file-name "site-lisp" user-emacs-directory)))
  (normal-top-level-add-subdirs-to-load-path))

(require 'init-elpaca)
(require 'init-core)
(require 'init-ui)
(require 'init-keybindings)
(require 'init-editing)
(require 'init-completion)
(require 'init-consult)
(require 'init-dired)
(require 'init-org)
(require 'init-net)
(require 'init-eshell)
(require 'init-ghostel)
(require 'init-project)
(require 'init-compile)
(require 'init-jinx)
(require 'init-git)
(require 'init-ai)
(require 'init-flymake)
(require 'init-prog)
(require 'init-eglot)
(require 'init-zen-mode)
(require 'init-pdf)
(require 'init-qemu)

(require 'init-c)
(require 'init-java)
(require 'init-js)
(require 'init-sql)
(require 'init-web)

;;; site-lisp

;;; Abandoned
;; (require 'init-treesitter)
;; (require 'init-flycheck)
;; (require 'init-lsp)
;; (require 'init-lsp-booster)
;; (require 'init-treemacs)

;;; init.el ends here
