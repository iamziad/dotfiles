;;; gruvbox-toggle.el --- Toggle between `gruvbox' and `gruvbox-light' -*- lexical-binding: t -*-

;; Author: Ziad Ahmed

(defvar my/theme 'gruvbox
  "Currently active Gruvbox variant. Same var your init.el already
sets before the first `load-theme' call — this file just reuses it.")

(defun my/gruvbox-set-theme (variant)
  "Force Emacs onto Gruvbox VARIANT, either `dark' or `light'.
Idempotent, unlike `my/gruvbox-toggle-theme' -- calling it twice with
the same VARIANT is a no-op. Meant to be driven from outside Emacs
too, e.g.:

  emacsclient --eval \"(my/gruvbox-set-theme (quote dark))\"

so a shell-level switcher (GTK, Alacritty, ...) can push the same
decision into a running daemon instead of each toggling independently
and drifting out of sync."
  (let ((target (pcase variant
                  ('dark 'gruvbox)
                  ('light 'gruvbox-light)
                  (_ (error "my/gruvbox-set-theme: variant must be `dark' or `light', got %S" variant)))))
    (unless (eq my/theme target)
      (setq my/theme target)
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme my/theme t))
    (message "Theme: %s" my/theme)))

(defun my/gruvbox-toggle-theme ()
  "Flip `my/theme' between `gruvbox' and `gruvbox-light' in one call."
  (interactive)
  (my/gruvbox-set-theme (if (eq my/theme 'gruvbox) 'light 'dark)))

(global-set-key (kbd "C-z g t") #'my/gruvbox-toggle-theme)

(defun my-remap-fringe ()
  (face-remap-add-relative 'fringe
                           :background (face-attribute 'default :background)))

(dolist (hook '(minibuffer-setup-hook
                eshell-mode-hook
                magit-mode-hook
                compilation-mode-hook))
  (add-hook hook #'my-remap-fringe))

(provide 'gruvbox-toggle)

;;; gruvbox-toggle.el ends here
