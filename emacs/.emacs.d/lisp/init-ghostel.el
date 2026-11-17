;;; init-ghostel.el --- Ghostel terminal integration -*- lexical-binding: t; -*-

(defun my/ghostel-send-C-k-and-kill ()
  "Send `C-k' to Ghostel while also copying the line to the kill ring."
  (interactive)
  (kill-ring-save (point) (line-end-position))
  (ghostel-send-key "k" "ctrl"))

(defun my/ghostel-send-C-p ()
  "Send `C-p' to Ghostel."
  (interactive)
  (ghostel-send-key "p" "ctrl"))

(defun my/ghostel-send-C-n ()
  "Send `C-n' to Ghostel."
  (interactive)
  (ghostel-send-key "n" "ctrl"))

(use-package ghostel
  :ensure t
  :hook (after-init . ghostel-status-indicator-mode)
  :bind (("C-x m" . ghostel)
         ("C-`"   . ghostel-list-buffers))
  :config
  ;; The semi-char keymap is defined by Ghostel, so bind after it loads.
  (keymap-set ghostel-semi-char-mode-map "C-k" #'my/ghostel-send-C-k-and-kill)
  (keymap-set ghostel-semi-char-mode-map "M-p" #'my/ghostel-send-C-p)
  (keymap-set ghostel-semi-char-mode-map "M-n" #'my/ghostel-send-C-n)

  (ghostel-compile-global-mode 1)
  (add-to-list 'ghostel-eval-cmds
               '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-project
  :ensure nil
  :after ghostel
  :config
  (keymap-set project-prefix-map "m" #'ghostel-project)
  (keymap-set project-prefix-map "M" #'ghostel-project-list-buffers)
  (add-to-list 'project-switch-commands
               '(ghostel-project "Ghostel" ?m)
               t))

(use-package ghostel-eshell
  :ensure nil
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(provide 'init-ghostel)
;;; init-ghostel.el ends here
