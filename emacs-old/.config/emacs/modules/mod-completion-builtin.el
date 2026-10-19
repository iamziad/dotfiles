;; -*- lexical-binding: t; -*-

;; Replaces Corfu
(use-package completion-preview
  :straight nil
  :demand t
  :diminish completion-preview-mode
  :bind
  ( :map completion-preview-active-mode-map
    ("M-i" . completion-preview-insert-word)
    ("C-j" . completion-preview-next-candidate)
    ("C-k" . completion-preview-prev-candidate)
    ("C-e" . completion-preview-insert)
    ;; With TAB we effectively defer to the *Completions* buffer to
    ;; show more completion candidates at once.
    ("<tab>" . completion-preview-complete))
  :config
  (setq completion-preview-minimum-symbol-length 2)
  (with-eval-after-load 'org
    (add-to-list 'completion-preview-commands #'org-self-insert-command))
  (global-completion-preview-mode 1))

(use-package minibuffer
  :straight nil
  :demand t
  :bind
  ( :map completion-in-region-mode-map
    ("M-i" . minibuffer-choose-completion)
    ("C-j" . minibuffer-next-completion)
    ("C-k" . minibuffer-previous-completion)
    ("C-h" . minibuffer-previous-column-completion)
    ("C-l" . minibuffer-next-column-completion)
    ("C-k" . minibuffer-previous-completion))
  :config
  (setq completions-format 'vertical)
  (setq completions-sort 'historical)
  (setq completions-max-height 14)
  (setq completion-auto-help t)
  (setq completion-auto-select nil)
  (setq completion-auto-wrap nil)
  (setq minibuffer-visible-completions t)
  (setq completion-eager-update t))

;; Replaces Vertico
(use-package icomplete
  :straight nil
  :demand t
  :bind
  ( :map icomplete-minibuffer-map
    ("C-j" . icomplete-forward-completions)
    ("C-k" . icomplete-backward-completions)
    ("RET" . icomplete-force-complete-and-exit)
    ("M-RET" . exit-minibuffer)
    ("TAB" . icomplete-force-complete))
  :config
  (setq icomplete-show-matches-on-no-input t)
  (setq icomplete-compute-delay 0)
  (setq icomplete-hide-common-prefix nil)
  (setq icomplete-scroll t)
  (setq max-mini-window-height 12)
  (icomplete-mode 1)
  (icomplete-vertical-mode 1))


(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides
        '((file (styles basic partial-completion))
          (lsp-capf (styles orderless basic)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package dabbrev
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
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
                                 comint-mode-hook eshell-mode-hook))
    (add-hook hook
              (defun my/corfu-add-cape-dabbrev-h ()
                (add-hook 'completion-at-point-functions #'cape-dabbrev 20 t))))
  :config
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'comint-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'pcomplete-completions-at-point :around #'cape-wrap-nonexclusive))

(provide 'mod-completion-builtin)
