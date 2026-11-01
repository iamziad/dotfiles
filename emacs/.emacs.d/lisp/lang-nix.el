(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . (lambda ()
                      (add-hook 'before-save-hook #'nix-mode-format nil t))))

(use-package envrc
  :config
  (when (executable-find "direnv")
    (envrc-global-mode 1)))
