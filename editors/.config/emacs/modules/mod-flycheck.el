;;; mod-flycheck.el

(use-package flycheck
  :init (global-flycheck-mode 1)
  :bind
  (("M-n"     . flycheck-next-error)
   ("M-p"     . flycheck-previous-error)))

(setq flycheck-display-errors-function #'flycheck-display-error-messages)
(setq flycheck-display-errors-delay 0.2)

(use-package flycheck-inline
  :hook
  (flycheck-mode . flycheck-inline-mode))

(provide 'mod-flycheck)

;;; mod-flycheck.el ends here
