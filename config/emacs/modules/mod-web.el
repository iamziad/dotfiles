;;; mod-web.el  -*- lexical-binding: t; -*-


(use-package add-node-modules-path
  :ensure t
  :hook ((js-mode . add-node-modules-path)
         (js2-mode . add-node-modules-path)
         (typescript-mode . add-node-modules-path)
         (typescript-ts-mode . add-node-modules-path)
         (tsx-ts-mode . add-node-modules-path)
         (json-ts-mode . add-node-modules-path)
         (web-mode . add-node-modules-path)))

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
  (web-mode-enable-current-column-highlight t)
  :bind
  (:map web-mode-map
        ;; Navigation & Selection
        ("M-n" . web-mode-element-next)
        ("M-p" . web-mode-element-previous)
        ("M-P" . web-mode-element-parent)
        ("M-N" . web-mode-element-child)
        ("C-c C-e s" . web-mode-element-select)

        ;; Editing & DOM Manipulation
        ("C-c C-e w" . web-mode-element-wrap)
        ("C-c C-e r" . web-mode-element-rename)
        ("C-c C-e k" . web-mode-element-kill)
        ("C-c C-e i" . web-mode-element-insert-at-point)
        ("C-c C-e t" . web-mode-element-transpose)

        ;; Tag Closing & Folding
        ("C-c C-f"   . web-mode-tag-match)
        ("C-c /"     . web-mode-element-close)
        ("C-c C-e f" . web-mode-element-children-fold-or-unfold)))

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

(use-package rainbow-mode
  :ensure t
  :defer t
  :config
  (rainbow-mode +1))

(provide 'mod-web)
;;; mod-web.el ends here
