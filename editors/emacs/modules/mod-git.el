;;; mod-git.el --- Git -*- lexical-binding: t; -*-

(use-package magit
  :ensure t
  :after transient
  :commands (magit-status)
  :hook ((magit-mode git-commit-mode) . (lambda () (variable-pitch-mode -1)))
  :bind (("C-x g" . magit-status)
         ("C-x v" . magit-diff-visit-file-other-window)))

(setq magit-repository-directories '(("~/dotfiles/" . 0) ("~/Projects"  . 2)))


;; (use-package diff-hl
;;   :ensure t
;;   :config
;;   (global-diff-hl-mode 1)
;;   (setq diff-hl-fringe-bmp-function #'diff-hl-fringe-bmp-from-type)
;;   (diff-hl-show-hunk-mouse-mode)
;;   (diff-hl-flydiff-mode 1)
;;   (add-hook 'magit-pre-refresh-hook  'diff-hl-magit-pre-refresh)
;;   (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
;;   (add-hook 'dired-mode-hook 'diff-hl-dired-mode))


(provide 'mod-git)
;;; mod-git.el ends here
