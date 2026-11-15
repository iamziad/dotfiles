;;; Markdown  -*- lexical-binding: t; -*-

(use-package markdown-mode
  :ensure t
  :mode
  ("\\.md\\'" . gfm-mode)
  :hook
  ((markdown-mode) .
   (lambda ()
     outline-minor-mode
     ))
  :custom-face
  (markdown-code-face ((t (:inherit default)))))

(provide 'init-markdown)
