;;; gruvbox-toggle.el --- Toggle between `gruvbox' and `gruvbox-light' -*- lexical-binding: t -*-

;; Author: Ziad Ahmed

;; custom-theme-load-path only makes `load-theme' find the .el files —
;; it does NOT put them on `load-path', so a plain `require' for this
;; file won't resolve unless you also add the themes dir to `load-path'
;; (or `load-file' this by full path). See the note at the bottom.

(defvar my/theme 'gruvbox
  "Currently active Gruvbox variant. Same var your init.el already
sets before the first `load-theme' call — this file just reuses it.")

(defun my/gruvbox-toggle-theme ()
  "Flip `my/theme' between `gruvbox' and `gruvbox-light' in one call.
No trip through `customize-themes' or `load-theme' by hand."
  (interactive)
  (setq my/theme (if (eq my/theme 'gruvbox) 'gruvbox-light 'gruvbox))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme my/theme t)
  (message "Theme: %s" my/theme))

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
