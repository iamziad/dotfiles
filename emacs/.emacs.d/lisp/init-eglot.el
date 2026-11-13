
;; -*- lexical-binding: t; -*-

(use-package eglot
  :ensure t
  :commands (eglot eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect nil)
  (eglot-connect-timeout 30)
  (eglot-events-buffer-size 1000)
  (eglot-send-changes-idle-time 0.4)
  (eglot-extend-to-xref t)
  :config
  (defun my/eglot-enable-inlay-hints ()
    "Enable inlay hints when the connected server supports them."
    (when (and (eglot-managed-p)
               (fboundp 'eglot-inlay-hints-mode))
      (eglot-inlay-hints-mode 1)))

  (add-hook 'eglot-managed-mode-hook
            #'my/eglot-enable-inlay-hints)

  (define-key eglot-mode-map (kbd "C-c l a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l f") #'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c l o") #'eglot-code-actions-organize-imports)
  (define-key eglot-mode-map (kbd "C-c l q") #'eglot-shutdown))

(with-eval-after-load 'eglot
  (dolist (face '(eglot-semantic-declaration
                  eglot-semantic-modifier
                  eglot-semantic-namespace
                  eglot-semantic-readonly))
    (set-face-attribute face nil
                        :inherit 'unspecified
                        :foreground 'unspecified
                        :background 'unspecified)))

;;;; Debugging

(use-package dape
  :ensure t
  :init
  (setq dape-key-prefix "\C-cd")
  :custom
  (dape-buffer-window-arrangement 'right))

(use-package emacs
  :straight nil
  :custom
  (window-sides-vertical t))

(provide 'lang-eglot)
