;; -*- lexical-binding: t; -*-

(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2
      json-ts-mode-indent-offset 2)

(dolist (ext '("js" "cjs" "mjs" "jsx"))
  (add-to-list 'auto-mode-alist
               (cons (concat "\\." ext "\\'") 'js-ts-mode)))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-ts-mode))

(use-package add-node-modules-path
  :hook ((js-mode js-jsx-mode js-ts-mode
                  typescript-ts-mode tsx-ts-mode
                  json-ts-mode) . add-node-modules-path))

;; Chain eslint
(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-diagnostics-mode-hook
            (lambda ()
              (flycheck-add-next-checker 'lsp '(t . javascript-eslint)))))

(provide 'lang-javascript)
