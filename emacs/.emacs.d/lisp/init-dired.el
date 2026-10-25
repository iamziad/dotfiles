;; -*- lexical-binding: t; -*-

(require 'dired-x)

(setq dired-listing-switches "-alh --group-directories-first")
(setq dired-dwim-target t)
(setq delete-by-moving-to-trash t)
(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-auto-revert-buffer t)
(setq dired-mouse-drag-files t)
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
(setq image-dired-thumb-size 250)
(setq image-dired-thumbnail-storage 'standard)

(use-package async
  :ensure t
  :init
  (dired-async-mode 1))

(use-package dired-open-with
  :ensure t
  :after dired
  :bind
  (:map dired-mode-map
        ("b" . dired-open-with)))

(use-package nerd-icons-dired
  :config
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package dired-git-info
  :ensure t
  :after dired
  :custom
  (dgi-auto-hide-details-p nil)
  :bind
  (:map dired-mode-map
        (")" . dired-git-info-mode)))

(use-package dired-subtree
  :after dired
  :custom (dired-subtree-use-backgrounds nil)
  :bind (:map dired-mode-map
              ("TAB" . dired-subtree-toggle)))

(provide 'init-dired)
