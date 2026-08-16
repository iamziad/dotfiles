;;; mod-web.el  -*- lexical-binding: t; -*-

(use-package web-mode
  :ensure t
  :mode ("\\.phtml\\'"
         "\\.tpl\\.php\\'"
         "\\.tpl\\'"
         "\\.hbs\\'"
         "\\.blade\\.php\\'"
         "\\.jsp\\'"
         "\\.as[cp]x\\'"
         "\\.erb\\'"
         "\\.mustache\\'"
         "\\.njk\\'"
         "\\.jinja2?\\'"
         "\\.svelte\\'"
         "\\.vue\\'"
         "\\.html?\\'"
         "/\\(views\\|html\\|theme\\|templates\\)/.*\\.php\\'")
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  ;; Let smartparens handle pairing instead of web-mode's built-in
  (web-mode-enable-auto-pairing nil)
  (web-mode-enable-current-element-highlight t)
  (web-mode-enable-current-column-highlight t))

;; smartparens integration for ERB/EJS-style template tags
(with-eval-after-load 'web-mode
  (sp-with-modes '(web-mode)
    (sp-local-pair "%" "%"
                   :unless '(sp-in-string-p)
                   :post-handlers '(((lambda (&rest _ignored)
                                       (just-one-space)
                                       (save-excursion (insert " ")))
                                     "SPC" "=" "#")))
    (sp-local-tag "%" "<% "  " %>")
    (sp-local-tag "=" "<%= " " %>")
    (sp-local-tag "#" "<%# " " %>")))


(use-package emmet-mode
  :ensure t
  :hook ((html-ts-mode web-mode css-ts-mode sgml-mode css-mode) . emmet-mode)
  :config
  (setq emmet-move-cursor-between-quotes t)
  (define-key emmet-mode-keymap (kbd "TAB") 'emmet-expand-line)
  (with-eval-after-load 'emmet-mode
    (define-key emmet-mode-keymap (kbd "C-j") nil)))

;; (use-package rainbow-mode
;;   :ensure t
;;   :defer t
;;   :config
;;   (rainbow-mode +1))


(provide 'mod-web)
;;; mod-web.el ends here
