;; ;; ;; -*- lexical-binding: t; -*-

(use-package yasnippet
  :ensure t
  :custom
  (yas-snippet-dirs
   (list (expand-file-name "snippets/" user-emacs-directory)))
  :config
  (yas-global-mode 1))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto-prefix 2)
  (corfu-separator ?\s)
  (corfu-preview-current t)
  (corfu-preselect 'first)
  (corfu-quit-at-boundary 'separator)
  (corfu-quit-no-match 'separator)
  (corfu-count 16)
  (corfu-min-width 45)
  (corfu-max-width 120)
  (corfu-popupinfo-delay '(0.5 . 1.0))
  :hook
  (corfu-mode . corfu-history-mode)
  (corfu-mode . corfu-popupinfo-mode)
  (minibuffer-setup . (lambda () (corfu-mode -1)))
  :init
  (global-corfu-mode)
  :config
  (setq tab-always-indent 'complete)
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history))

  (defun my/corfu-enable-auto ()
    (setq-local corfu-auto t))

  (dolist (hook '(emacs-lisp-mode-hook
                  c-mode-hook
                  c-ts-mode-hook
                  html-mode-hook
                  mhtml-mode-hook
                  css-mode-hook
                  scss-mode-hook
                  web-mode-hook
                  conf-mode-hook
                  html-ts-mode-hook
                  css-ts-mode-hook))
    (add-hook hook #'my/corfu-enable-auto))

  (with-eval-after-load 'cc-mode
    (define-key c-mode-base-map (kbd "TAB") #'indent-for-tab-command))
  )

(use-package dabbrev
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (defvar my/corfu-buffer-scanning-size-limit (* 1 1024 1024))
  (defun my/corfu-dabbrev-friend-buffer-p (other-buffer)
    (< (buffer-size other-buffer) my/corfu-buffer-scanning-size-limit))
  (setq dabbrev-friend-buffer-function #'my/corfu-dabbrev-friend-buffer-p
        dabbrev-upcase-means-case-search t
        dabbrev-case-replace nil)
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'authinfo-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

(use-package cape
  :init
  (add-hook 'prog-mode-hook
            (defun my/corfu-add-cape-file-h ()
              (add-hook 'completion-at-point-functions #'cape-file -10 t)))
  (add-hook 'org-mode-hook
            (defun my/corfu-add-cape-elisp-block-h ()
              (add-hook 'completion-at-point-functions #'cape-elisp-block 0 t)))
  (setq cape-dabbrev-check-other-buffers t)
  (dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook
                                 comint-mode-hook minibuffer-setup-hook eshell-mode-hook))
    (add-hook hook
              (defun my/corfu-add-cape-dabbrev-h ()
                (add-hook 'completion-at-point-functions #'cape-dabbrev 20 t))))
  :config
  ;; lsp-mode's `lsp-completion-at-point' advice dropped — that function no
  ;; longer exists now that lsp-mode is gone; eglot's equivalent is advised
  ;; below instead.
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-noninterruptible)
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'comint-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'pcomplete-completions-at-point :around #'cape-wrap-nonexclusive))

(use-package kind-icon
  :config
  (setq kind-icon-default-face 'corfu-default)
  (setq kind-icon-default-style '(:padding 0 :stroke 0 :margin 0 :radius 0 :height 0.9 :scale 1))
  (setq kind-icon-blend-frac 0.08)
  (setq kind-icon-use-icons nil)
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
  (add-hook 'counsel-load-theme #'(lambda () (interactive) (kind-icon-reset-cache)))
  (add-hook 'load-theme         #'(lambda () (interactive) (kind-icon-reset-cache))))

(use-package completion-preview
  :ensure nil
  :custom
  (completion-preview-minimum-symbol-length 2)
  :config
  (define-key completion-preview-active-mode-map (kbd "M-]") #'completion-preview-next-candidate)
  (define-key completion-preview-active-mode-map (kbd "M-[") #'completion-preview-prev-candidate)
  (setq global-completion-preview-modes
        '(not minibuffer-mode
              emacs-lisp-mode
              lisp-interaction-mode
              c-mode
              c-ts-mode
              html-mode
              mhtml-mode
              css-mode
              scss-mode
              web-mode
              conf-mode
              html-ts-mode
              css-ts-mode))
  (global-completion-preview-mode 1))

(provide 'init-completion)
