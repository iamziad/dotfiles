;; -*- lexical-binding: t; -*-

(use-package syntax-subword
  :custom (syntax-subword-skip-spaces t)
  :diminish syntax-subword-mode
  :config
  (global-syntax-subword-mode -1)
  (global-set-key (kbd "M-F") #'syntax-subword-forward)
  (global-set-key (kbd "M-B") #'syntax-subword-backward)
  (global-set-key (kbd "M-D") #'syntax-subword-kill)
  (global-set-key (kbd "<M-S-backspace>") #'syntax-subword-backward-kill))

(use-package iy-go-to-char
  :vc (:url "https://github.com/emacsattic/iy-go-to-char")
  :bind* (("C-'" . iy-go-to-char)
          ("C-;" . iy-go-to-char-backward)))

(use-package symbol-overlay
  :bind (("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev))
  :hook (prog-mode . symbol-overlay-mode)
  :diminish symbol-overlay-mode)

(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode)
  :diminish hs-minor-mode
  :config
  (defun toggle-fold ()
    "Toggle folding of the block at the end of the current line."
    (interactive)
    (save-excursion
      (end-of-line)
      (hs-toggle-hiding)))
  (keymap-global-set "C-c t f" #'toggle-fold))

(use-package smart-hungry-delete
  :bind (([remap backward-delete-char-untabify] . smart-hungry-delete-backward-char)
         ([remap delete-backward-char]          . smart-hungry-delete-backward-char)
         ([remap delete-char]                   . smart-hungry-delete-forward-char))
  :init (smart-hungry-delete-add-default-hooks))

(use-package whitespace-cleanup-mode
  :custom
  (whitespace-cleanup-mode-preserve-point t)
  (whitespace-cleanup-mode-only-if-initially-clean nil)
  :diminish whitespace-cleanup-mode
  :config (global-whitespace-cleanup-mode +1))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package multiple-cursors
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-M-<"   . mc/skip-to-previous-like-this)
         ("C-M->"   . mc/skip-to-next-like-this)
         ("C-c m d" . mc/mark-all-dwim)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . electric-newline-and-maybe-indent)
         ("C-c m e" . mc/edit-lines))
  :config
  (require 'mc-hide-unmatched-lines-mode)
  (setq mc/always-run-for-all t))

(provide 'init-editing)
