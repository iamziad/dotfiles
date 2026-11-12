;;; init-completion.el --- Completion setup -*- lexical-binding: t; -*-

(defvar my/auto-completion-modes
  '(emacs-lisp-mode lisp-interaction-mode
                    c-mode c-ts-mode
                    html-mode mhtml-mode html-ts-mode
                    css-mode css-ts-mode scss-mode
                    web-mode conf-mode)
  ".")

(use-package yasnippet
  :ensure t
  :custom
  (yas-snippet-dirs
   (list (expand-file-name "snippets/" user-emacs-directory)))
  :config
  (yas-global-mode 1))

(use-package completion-preview
  :straight nil
  :demand t
  :config
  (setq completion-preview-minimum-symbol-length 3)
  (define-key completion-preview-active-mode-map (kbd "M-]") #'completion-preview-next-candidate)
  (define-key completion-preview-active-mode-map (kbd "M-[") #'completion-preview-prev-candidate)
  (setq global-completion-preview-modes
        `(not minibuffer-mode
              ,@my/auto-completion-modes))
  (global-completion-preview-mode 1))

(use-package vertico
  :init
  (vertico-mode))

(use-package vertico-directory
  :straight nil
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

;; (use-package vertico-posframe
;;   :config
;;   (vertico-posframe-mode 1))

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
  :hook
  (corfu-mode . corfu-history-mode)
  (minibuffer-setup . (lambda () (corfu-mode -1)))
  :init
  (global-corfu-mode)
  :config
  (setq tab-always-indent 'complete)
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history))
  (defun my/corfu-enable-auto ()
    (setq-local corfu-auto t))
  (dolist (mode my/auto-completion-modes)
    (add-hook (intern (format "%s-hook" mode)) #'my/corfu-enable-auto))
  (with-eval-after-load 'cc-mode
    (define-key c-mode-base-map (kbd "TAB") #'indent-for-tab-command)))

(use-package corfu-popupinfo
  :after corfu
  :straight nil
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :config
  (corfu-popupinfo-mode 1))

(use-package dabbrev
  :straight nil
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :custom
  (dabbrev-upcase-means-case-search t)
  (dabbrev-case-replace nil)
  (dabbrev-friend-buffer-function
   (lambda (buffer)
     (< (buffer-size buffer) (* 1024 1024))))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'authinfo-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode))

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
    (defun my/cape-add-dabbrev ()
      (add-hook 'completion-at-point-functions #'cape-dabbrev 20 t))

    (dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook
                                   comint-mode-hook minibuffer-setup-hook eshell-mode-hook))
      (add-hook hook #'my/cape-add-dabbrev)))
  :config
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-noninterruptible)
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'comint-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'pcomplete-completions-at-point :around #'cape-wrap-nonexclusive))

(provide 'init-completion)
;;; init-completion.el ends here
