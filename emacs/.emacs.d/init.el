;; -*- lexical-binding: t; -*-

(require 'package)
(package-initialize)

;; Load the modules from ./lisp.
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Customize writes to its own file, never into this file or the modules.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t t)

(require 'init-defaults)
(require 'init-ui)
(require 'init-completion)
(require 'init-editing)
(require 'init-keys)
(require 'init-editing)
(require 'init-dired)
(require 'init-compile)
(require 'init-org)
(require 'init-projectile)
(require 'init-git)
(require 'init-shell)
(require 'init-ai)
(require 'init-spelling)
(require 'init-dumb-jump)
(require 'init-flycheck)
(require 'init-literate-programming)
(require 'lang-c)
(require 'lang-javascript)
(require 'lang-sql)
