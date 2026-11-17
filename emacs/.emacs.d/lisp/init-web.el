;;; init-web.el --- Web development support -*- lexical-binding: t; -*-

;;;; Treesitter

(add-to-list 'auto-mode-alist '("\\.css\\'"   . css-ts-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'"  . json-ts-mode))

;;;; Web basics -------------------------------------------

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
  (web-mode-enable-auto-closing t)
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
        ("C-c C-e t" . web-mode-element-transpose)))

(use-package emmet-mode
  :ensure t
  :hook ((html-ts-mode mhtml-mode html-mode sgml-mode
                       css-ts-mode css-mode
                       js-jsx-mode tsx-ts-mode web-mode) . emmet-mode)
  :config
  (setq emmet-move-cursor-between-quotes t)
  (add-to-list 'emmet-css-major-modes 'css-ts-mode)
  (define-key emmet-mode-keymap (kbd "C-.") #'emmet-expand-line)
  (add-hook 'tsx-ts-mode-hook (lambda () (setq-local emmet-expand-jsx-className? t)))
  (add-hook 'js-ts-mode-hook  (lambda () (setq-local emmet-expand-jsx-className? t))))

(use-package auto-rename-tag
  :ensure t
  :diminish auto-rename-tag-mode
  :hook ((html-ts-mode mhtml-mode html-mode
                       js-ts-mode tsx-ts-mode web-mode) . auto-rename-tag-mode))

(use-package rainbow-mode
  :ensure t
  :hook ((css-mode css-ts-mode scss-mode web-mode html-ts-mode) . rainbow-mode))

(use-package sgml-mode
  :ensure nil
  :hook ((html-mode mhtml-mode web-mode) . sgml-electric-tag-pair-mode))

;;;; LSP - TypeScript, JavaScript, CSS, Astro, Vue, and Svelte ---------------------------------------

(use-package eglot-typescript-preset
  :ensure t
  :after eglot
  :custom
  (eglot-typescript-preset-lsp-server 'rass)
  (eglot-typescript-preset-rass-tools
   '(typescript-language-server eslint tailwindcss-language-server))
  (eglot-typescript-preset-css-lsp-server 'rass))

;;; HTML + Tailwindcss
(with-eval-after-load 'eglot
  (put 'web-mode 'eglot-language-id "html")
  (put 'mhtml-mode 'eglot-language-id "html")

  (add-to-list 'eglot-server-programs
               '((mhtml-mode html-mode web-mode html-ts-mode sgml-mode)
                 "rass" "--" "vscode-html-language-server" "--stdio"
                 "--" "tailwindcss-language-server" "--stdio")))

(use-package twind
  :ensure (:host github :repo "akirak/twind.el"))

(provide 'init-web)
;;; init-web.el ends here
