;; -*- lexical-binding: t; -*-

(use-package magit
  :custom
  (magit-diff-refine-hunk t)
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-save-repository-buffers 'dontask))

(use-package diff-hl
  :bind (("M-{" . diff-hl-previous-hunk)
         ("M-}" . diff-hl-next-hunk))
  :custom (diff-hl-update-async t)
  :init (global-diff-hl-mode)
  :config (diff-hl-flydiff-mode 1))

(provide 'init-git)
