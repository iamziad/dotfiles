;; -*- lexical-binding: t; -*-

;; (use-package avy
;;   :ensure t
;;   :demand t
;;   :bind (("C-c j" . avy-goto-char-2)
;;          ))

(use-package smart-hungry-delete
  :ensure t
  :bind (([remap backward-delete-char-untabify] . smart-hungry-delete-backward-char)
         ([remap delete-backward-char]          . smart-hungry-delete-backward-char)
         ([remap delete-char]                   . smart-hungry-delete-forward-char))
  :init (smart-hungry-delete-add-default-hooks))

(use-package whitespace-cleanup-mode
  :ensure t
  :custom
  (whitespace-cleanup-mode-preserve-point t)
  (whitespace-cleanup-mode-only-if-initially-clean nil)
  :diminish whitespace-cleanup-mode
  :config (global-whitespace-cleanup-mode +1))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package multiple-cursors
  :ensure t
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-M-<"   . mc/skip-to-previous-like-this)
         ("C-M->"   . mc/skip-to-next-like-this)
         ("C-c m d" . mc/mark-all-dwim)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . electric-newline-and-maybe-indent)
         ("C-c m e" . mc/edit-lines)
         ("<C-M-mouse-1>" . mc/add-cursor-on-click))
  :config
  (require 'mc-hide-unmatched-lines-mode)
  (setq mc/always-run-for-all t))

(use-package drag-stuff
  :ensure t
  :diminish drag-stuff-mode
  :config
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

(provide 'init-qof)
