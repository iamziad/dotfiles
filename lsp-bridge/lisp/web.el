;;;; Web  -*- lexical-binding: t; -*-

(setq css-indent-offset 2)

(use-package web-mode
  :mode
  (("\\.phtml\\'" . web-mode)
   ("\\.html?\\'" . web-mode)
   ("\\.php\\'" . web-mode)
   ("\\.tpl\\'" . web-mode)
   ("\\.[agj]sp\\'" . web-mode)
   ("\\.as[cp]x\\'" . web-mode)
   ("\\.erb\\'" . web-mode)
   ("\\.mustache\\'" . web-mode)
   ("\\.djhtml\\'" . web-mode))
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-enable-auto-closing t)
  (web-mode-enable-auto-pairing nil)
  (web-mode-enable-current-element-highlight t)
  (web-mode-enable-current-column-highlight t)
  :bind (:map web-mode-map
              ;; Navigation & selection
              ("M-n"       . web-mode-element-next)
              ("M-p"       . web-mode-element-previous)
              ("M-P"       . web-mode-element-parent)
              ("M-N"       . web-mode-element-child)
              ("C-c C-e s" . web-mode-element-select)
              ;; Editing & DOM manipulation
              ("C-c C-e w" . web-mode-element-wrap)
              ("C-c C-e r" . web-mode-element-rename)
              ("C-c C-e k" . web-mode-element-kill)
              ("C-c C-e i" . web-mode-element-insert-at-point)
              ("C-c C-e t" . web-mode-element-transpose)))

(use-package auto-rename-tag
  :hook ((web-mode html-mode html-ts-mode mhtml-mode
                   rjsx-mode js-ts-mode tsx-ts-mode) . auto-rename-tag-mode)
  :diminish auto-rename-tag-mode)

(use-package rainbow-mode
  :hook ((css-mode css-ts-mode html-mode html-ts-mode web-mode) . rainbow-mode)
  :diminish rainbow-mode)

(provide 'web)
