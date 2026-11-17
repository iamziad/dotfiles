;; -*- lexical-binding: t; -*-

(defvar my/eglot-ensure
  '(java-mode
    c-mode
    js-ts-mode
    typescript-ts-mode
    tsx-ts-mode
    css-ts-mode
    mhtml-mode
    mhtml-ts-mode
    html-mode
    web-mode
    html-ts-mode
    sgml-mode
    css-mode
    json-ts-mode))

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

  (defvar-local my/eglot-hints-refresh-timer nil)

  (defun my/eglot-schedule-hints-refresh (&rest _)
    "Force jit-lock to re-request inlay hints shortly after edits settle."
    (when (bound-and-true-p eglot-inlay-hints-mode)
      (when (timerp my/eglot-hints-refresh-timer)
        (cancel-timer my/eglot-hints-refresh-timer))
      (setq my/eglot-hints-refresh-timer
            (run-with-idle-timer
             (+ eglot-send-changes-idle-time 0.5)
             nil
             (lambda (buf)
               (when (buffer-live-p buf)
                 (with-current-buffer buf
                   (jit-lock-refontify))))
             (current-buffer)))))

  (defun my/eglot-setup-hints-refresh ()
    "Hook a local after-change-functions entry to refresh inlay hints."
    (add-hook 'after-change-functions
              #'my/eglot-schedule-hints-refresh nil t))

  (add-hook 'eglot-managed-mode-hook #'my/eglot-setup-hints-refresh)

  (define-key eglot-mode-map (kbd "C-c l a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l f") #'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c l o") #'eglot-code-actions-organize-imports)
  (define-key eglot-mode-map (kbd "C-c l q") #'eglot-shutdown))

(defun my/eglot-organize-imports ()
  "Ask the current language server to organize imports.
Emacs 31 removed `eglot-code-actions-organize-imports', so use the standard
code-action entry point with the `source.organizeImports' kind."
  (interactive)
  (eglot-code-actions (point) nil "source.organizeImports"))

(with-eval-after-load 'eglot
  (dolist (face '(eglot-highlight-symbol-face
                  eglot-semantic-declaration
                  eglot-semantic-modifier
                  eglot-semantic-namespace
                  eglot-semantic-static
                  eglot-semantic-readonly))
    (set-face-attribute face nil
                        :inherit 'unspecified
                        :foreground 'unspecified
                        :background 'unspecified)))

;;;; Documentation
(use-package eldoc-box
  :ensure t
  :commands (eldoc-box-help-at-point)
  :custom
  (eldoc-box-max-pixel-width 600)
  (eldoc-box-max-pixel-height 400)
  :bind
  ("C-c l h" . eldoc-box-help-at-point))

(provide 'init-eglot)
