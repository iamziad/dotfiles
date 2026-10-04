;;; mod-shell.el -*- lexical-binding: t; -*-

;; GUI Emacs from a desktop launcher misses the shell PATH (node, jdtls, clangd).
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :demand t
  :custom
  (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-variables '("PATH" "MANPATH" "JAVA_HOME"))
  :config (exec-path-from-shell-initialize))

;; (use-package envrc
;;   :straight t
;;   :hook (after-init . envrc-global-mode))

(use-package fish-mode
  :straight t
  :mode (("\\.fish\\'" . fish-mode))
  :hook (fish-mode . (lambda ()
                       (add-hook 'before-save-hook 'fish_indent-before-save))))

(provide 'mod-shell)
;;; mod-shell.el ends here
