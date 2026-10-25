;; -*- lexical-binding: t; -*-

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      json-ts-mode-indent-offset 2)

(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-jsx-mode))

(use-package add-node-modules-path
  :hook ((js-mode js-jsx-mode js-ts-mode
                  typescript-ts-mode tsx-ts-mode
                  json-ts-mode) . add-node-modules-path))

(provide 'lang-javascript)
