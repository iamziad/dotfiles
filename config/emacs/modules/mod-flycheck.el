;;; mod-flycheck.el
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  :config
  (setq flycheck-display-errors-function #'flycheck-display-error-messages)
  (setq flycheck-display-errors-delay 0.2)
  :bind
  (("C-c C-e n" . flycheck-next-error)
   ("C-c C-e p" . flycheck-previous-error)))

(add-hook 'lsp-diagnostics-mode-hook
          (lambda ()
            (when (flycheck-valid-checker-p 'lsp)
              (flycheck-add-next-checker 'lsp 'javascript-eslint))))

(use-package flycheck-inline
  :ensure t
  :hook
  (flycheck-mode . flycheck-inline-mode))

(provide 'mod-flycheck)
;;; mod-flycheck.el ends here
