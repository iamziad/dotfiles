;;; modules.el --- Module toggle switchboard -*- lexical-binding: t; -*-

(require 'mod-essential-packages)
(require 'mod-navigation)
;; (require 'mod-evil)      ; vim keybindings - mutually exclusive with mod-nav
(require 'mod-completion)
(require 'mod-project)
(require 'mod-git)
(require 'mod-treesitter)   ; load before lsp: sets major-mode-remap-alist
(require 'mod-flycheck)
;; (require 'mod-flymake)
(require 'mod-lsp)
(require 'mod-smartparens)
(require 'mod-org)
(require 'mod-literate-programming)
(require 'mod-olivetti)
(require 'mod-shell)
(require 'mod-eww)
(require 'mod-pdf)
;; (require 'mod-crux)
(require 'mod-programming)
(require 'mod-apheleia)
(require 'mod-yasnippets)
(require 'mod-web)

(provide 'modules)

;;; modules.el ends here
