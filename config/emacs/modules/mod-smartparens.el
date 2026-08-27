;;; mod-smartparens.el --- Structural editing -*- lexical-binding: t; -*-

;; Supersedes electric-pair-mode: smartparens handles both auto-pairing
;; and structural (paredit-style) editing. electric-pair-mode is never
;; turned on in core-editor.el, precisely so it doesn't fight this module
;; over "who inserts the closing bracket."

(use-package smartparens
  :diminish 'smartparens-mode
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config)

  ;; (defun my/sp-open-line-between-braces (&rest _)
  ;;   (save-excursion
  ;;     (newline)
  ;;     (indent-according-to-mode))
  ;;   (indent-according-to-mode))

  ;; (sp-pair "{" nil :post-handlers '((my/sp-open-line-between-braces "RET")))

  :bind
  ("C-c s r" . sp-rewrap-sexp))

(provide 'mod-smartparens)
;;; mod-smartparens.el ends here
