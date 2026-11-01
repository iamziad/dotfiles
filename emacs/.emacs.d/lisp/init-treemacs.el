;; -*- lexical-binding: t; -*-

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (setq treemacs-width 35
        ;; treemacs-resize-icons 15
        treemacs-filewatch-mode t
        treemacs-indentation 2
        treemacs-is-never-other-window t
        treemacs-show-cursor t
        treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
        treemacs-silent-refresh nil
        treemacs-silent-filewatch nil
        treemacs-show-hidden-files t)
  (treemacs-project-follow-mode 1)
  (treemacs-follow-mode 1)
  ;; :custom
  ;; (treemacs-no-png-images t)
  :bind
  (("C-c t t" . treemacs)
   ("C-c t 1" . treemacs-delete-other-windows)
   ("C-c t d" . treemacs-select-directory)
   ("M-0"     . treemacs-select-window)))

;; (use-package nerd-icons
;;   :ensure t)

(use-package treemacs-nerd-icons
  :ensure t
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(defun my/treemacs-open-in-tab ()
  "."
  (interactive)
  (let* ((btn (treemacs-node-at-point))
         (path (and btn (treemacs-button-get btn :path))))
    (when (and path (file-regular-p path))
      (tab-bar-new-tab)
      (delete-other-windows
      (find-file path)))))

(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map (kbd "t") #'my/treemacs-open-in-tab))

(provide 'init-treemacs)
