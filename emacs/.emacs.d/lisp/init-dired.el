;;; init-dired.el --- Dired configuration -*- lexical-binding: t; -*-

(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-ahlv --group-directories-first"
        dired-dwim-target t
        dired-kill-when-opening-new-dired-buffer t
        dired-auto-revert-buffer 'dired-directory-changed-p
        dired-mouse-drag-files t
        dired-movement-style 'bounded-files
        dired-deletion-confirmer 'y-or-n-p
        dired-recursive-deletes 'top
        dired-recursive-copies 'always))

(use-package dired-x
  :ensure nil
  :config
  (setq dired-omit-verbose nil
        dired-omit-files
        (concat "\\`[.]\\'"
                "\\|\\(?:\\.js\\)?\\.meta\\'"
                "\\|\\.\\(?:elc\\|a\\|o\\|pyc\\|pyo\\|swp\\|class\\)\\'"
                "\\|^\\.DS_Store\\'"
                "\\|^\\.\\(?:svn\\|git\\)\\'"
                "\\|^\\.ccls-cache\\'"
                "\\|^__pycache__\\'"
                "\\|^\\.project\\(?:ile\\)?\\'"
                "\\|^flycheck_.*"
                "\\|^flymake_.*"))
  (add-hook 'dired-mode-hook #'dired-omit-mode))

(use-package image-dired
  :ensure nil
  :custom
  (image-dired-thumb-size 250)
  (image-dired-thumbnail-storage 'standard))

(use-package async
  :ensure t
  :config
  (dired-async-mode 1))

(use-package dired-du
  :ensure t
  :after dired
  :config
  (setq dired-du-size-format t))

(use-package dired-open-with
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("b" . dired-open-with)))

(use-package dired-git-info
  :ensure t
  :after dired
  :custom
  (dgi-auto-hide-details-p nil)
  :bind (:map dired-mode-map
              (")" . dired-git-info-mode)))

(use-package dired-subtree
  :ensure t
  :after dired
  :custom
  (dired-subtree-use-backgrounds nil)
  :bind (:map dired-mode-map
              ("TAB" . dired-subtree-toggle)))

(provide 'init-dired)
;;; init-dired.el ends here
