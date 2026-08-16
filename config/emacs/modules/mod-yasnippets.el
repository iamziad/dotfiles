;;; mod-yasnippets.el

(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
  (yas-global-mode 1))

(provide 'mod-yasnippets)

;;; mod-yasnippets.el ends here
