;;; mod-shell.el

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (or (memq window-system '(x mac))
            (daemonp))
    (exec-path-from-shell-initialize)))

(use-package envrc
  :straight t
  :hook (after-init . envrc-global-mode))

(use-package fish-mode
  :straight t
  :mode (("\\.fish\\'" . fish-mode))
  :hook (fish-mode . (lambda ()
                       (add-hook 'before-save-hook 'fish_indent-before-save))))

(provide 'mod-shell)
;;; mod-shell.el ends here
