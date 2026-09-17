;;; mod-completion.el -*- lexical-binding: t; -*-

(use-package vertico
  :init
  (vertico-mode)
  :config
  (setq vertico-cycle t
        vertico-count 12)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-separator ?\s)
  (corfu-quit-at-boundary 'separator)
  (corfu-quit-no-match 'separator)
  ;; (corfu-preselect 'prompt)
  ;; (corfu-on-exact-match nil)
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
  (setq global-corfu-modes '((not help-mode gud-mode) t))
  (add-to-list 'completion-category-overrides `(lsp-capf (styles ,@completion-styles)))
  (add-hook 'minibuffer-setup-hook
            (lambda ()
              (corfu-mode -1)))
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package dabbrev
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (defvar my/corfu-buffer-scanning-size-limit (* 1 1024 1024))
  (defun my/corfu-dabbrev-friend-buffer-p (other-buffer)
    (< (buffer-size other-buffer) my/corfu-buffer-scanning-size-limit))
  (setq dabbrev-friend-buffer-function #'my/corfu-dabbrev-friend-buffer-p
        dabbrev-upcase-means-case-search t)
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
  (advice-add #'lsp-completion-at-point :around #'cape-wrap-noninterruptible)
  (advice-add #'lsp-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'comint-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-nonexclusive)
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

(provide 'mod-completion)
