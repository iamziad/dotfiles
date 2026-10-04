;;; mod-dired.el --- -*- lexical-binding: t; -*-

(require 'dired-x)

(use-package dired
  :straight nil
  :custom
  (dired-listing-switches "-lh --group-directories-first")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer t)
  (dired-mouse-drag-files t)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
  :config
  ;; (add-hook 'dired-mode-hook 'dired-hide-details-mode)
  (with-eval-after-load 'dired
    (put 'dired-jump 'repeat-map nil))
  (keymap-set dired-mode-map "b" #'dired-open-with))

(use-package async
  :ensure t
  :init
  (dired-async-mode 1))

(use-package dired-subtree
  :commands (dired-subtree-toggle dired-subtree-cycle)
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle))
  :config
  (setq dired-subtree-line-prefix "  ")
  (setq dired-subtree-use-backgrounds nil))

(use-package dired-sidebar
  :bind (("C-c e" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package image-dired
  :ensure nil
  :config
  (setq image-dired-thumb-size 250)
  (setq image-dired-thumbnail-storage 'standard))
;; :bind (:map dired-mode-map
;;             ("C-d i" . image-dired)))

(use-package dired-open-with
  :ensure t)

(provide 'mod-dired)
