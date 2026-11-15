;; -*- lexical-binding: t; -*-

(defvar my/eglot-ensure
  '(java-mode
    c-mode
    js-ts-mode
    typescript-ts-mode
    tsx-ts-mode
    css-ts-mode
    mhtml-mode
    html-mode
    web-mode
    html-ts-mode
    sgml-mode
    css-mode
    json-mode))

(use-package eglot
  :ensure nil
  :commands (eglot eglot-ensure)
  :init
  (dolist (mode my/eglot-ensure)
    (add-hook (intern (format "%s-hook" mode)) #'eglot-ensure))
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
  (dolist (face '(eglot-highlight-symbol-face
                  eglot-semantic-declaration
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
  :ensure nil
  :custom
  (window-sides-vertical t))

;;;; Breadcrumb
(use-package breadcrumb
  :ensure t
  :hook ((java-mode . breadcrumb-local-mode)))

(provide 'init-eglot)
