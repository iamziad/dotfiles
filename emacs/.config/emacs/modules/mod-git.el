;;; mod-git.el --- Git -*- lexical-binding: t; -*-

(use-package magit
  :ensure t
  :after transient
  :commands (magit-status)
  :hook ((magit-mode git-commit-mode) . (lambda () (variable-pitch-mode -1)))
  :bind (("C-x g" . magit-status)
         ("C-x v" . magit-diff-visit-file-other-window)))

(setq magit-repository-directories '(("~/Projects"  . 2)))

(use-package diff-hl
  :hook (;; (after-init          . global-diff-hl-mode)
         (dired-mode          . diff-hl-dired-mode)
         (magit-pre-refresh   . diff-hl-magit-pre-refresh)
         (magit-post-refresh  . diff-hl-magit-post-refresh))
  :bind(("C-c d h" . diff-hl-show-hunk))
  :custom
  (diff-hl-update-async t)
  (diff-hl-flydiff-delay 0.5)
  :config
  (diff-hl-flydiff-mode 1))

(provide 'mod-git)
;;; mod-git.el ends here
