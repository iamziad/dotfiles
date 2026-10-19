;;; mod-dired.el --- -*- lexical-binding: t; -*-

(require 'dired-x)

(use-package dired
  :straight nil
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer t)
  (dired-mouse-drag-files t)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  (setq image-dired-thumb-size 250)
  (setq image-dired-thumbnail-storage 'standard)
  :config
  (with-eval-after-load 'dired
    (put 'dired-jump 'repeat-map nil)))

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

(provide 'mod-dired)
