(use-package emmet-mode
  :straight t
  :hook ((html-ts-mode mhtml-mode html-mode sgml-mode
                       css-ts-mode css-mode
                       js-jsx-mode tsx-ts-mode) . emmet-mode)
  :config
  (setq emmet-move-cursor-between-quotes t)
  (add-to-list 'emmet-css-major-modes 'css-ts-mode)
  (define-key emmet-mode-keymap (kbd "C-c >") #'emmet-expand-line))

(use-package auto-rename-tag
  :straight t
  :diminish auto-rename-tag-mode
  :hook ((html-ts-mode mhtml-mode html-mode
                       js-ts-mode tsx-ts-mode) . auto-rename-tag-mode))

(use-package rainbow-mode
  :hook ((css-mode css-ts-mode scss-mode web-mode html-ts-mode) . rainbow-mode))
