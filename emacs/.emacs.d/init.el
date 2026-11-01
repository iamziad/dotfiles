;; -*- lexical-binding: t; -*-

(require 'package)
(package-initialize)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t t)

(setq user-full-name "Ziad Ahmed"
      user-mail-address "dev.ziadahmed@gmail.com")

;;;; Core
(require 'init-defaults)
(require 'init-ui)
(require 'init-completion)
(require 'init-editing)
(require 'init-keys)
(require 'init-dired)

;;;; Tools
(require 'init-compile)
(require 'init-projectile)
(require 'init-git)
(require 'init-shell)
(require 'init-dumb-jump)
(require 'init-prog)
(require 'init-consult)

;;;; Apps
(require 'init-org)
(require 'init-literate-prog)
(require 'init-dashboard)
(require 'init-eww)
(require 'init-elfeed)
(require 'init-ghostel)
(require 'init-ai)
(require 'init-pdf)
(require 'init-anki)
;; (require 'init-flyspell)
(require 'init-jinx)
(require 'init-treemacs)
(require 'init-zen-mode)
(require 'init-ednc)

;;;; LSP, checking, and debugging
(require 'init-flycheck)
;; (require 'init-eglot)
;; (require 'init-lsp-bridge)
(require 'init-lsp-mode)
(require 'init-lsp-booster)
(require 'init-dap-mode)

;;;; Langs
(require 'lang-c)
(require 'lang-javascript)
(require 'lang-sql)
;; (require 'lang-nix)
;; (require 'lang-web)
