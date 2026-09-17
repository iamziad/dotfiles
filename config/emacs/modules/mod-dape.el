;;; mod-dape.el --- -*- lexical-binding: t; -*-
(use-package dape
  :ensure t
  :config)

(use-package dape-toolbar
  :straight (:host github :repo "zsxh/dape-toolbar")
  :after dape
  :config
  (dape-toolbar-mode 1))

(provide 'mod-dape)
