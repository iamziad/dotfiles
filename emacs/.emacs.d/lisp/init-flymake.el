;;; init-flymake.el --- On-the-fly diagnostics -*- lexical-binding: t; -*-

(defun my/flymake-toggle-eol (&optional fancy)
  "Toggle Flymake diagnostics at end of line.
With a prefix argument, show all diagnostics instead of short ones."
  (interactive "P")
  (setq-local flymake-show-diagnostics-at-end-of-line
              (if flymake-show-diagnostics-at-end-of-line
                  nil
                (if fancy 'fancy 'short)))
  (when (bound-and-true-p flymake-mode)
    (flymake-mode -1)
    (flymake-mode 1))
  (message "Flymake EOL diagnostics: %s"
           (or flymake-show-diagnostics-at-end-of-line "off")))

(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-no-changes-timeout 0.8)
  (flymake-start-on-save-buffer t)
  (flymake-wrap-around nil)
  (flymake-indicator-type 'margins)
  (flymake-show-diagnostics-at-end-of-line nil)
  :config
  ;; `flymake-mode-map' is defined by Flymake itself, so these bindings must
  ;; be installed after the package has loaded.
  (keymap-set flymake-mode-map "C-c 1 n" #'flymake-goto-next-error)
  (keymap-set flymake-mode-map "C-c 1 p" #'flymake-goto-prev-error)
  (keymap-set flymake-mode-map "C-c 1 l" #'flymake-show-buffer-diagnostics)
  (keymap-set flymake-mode-map "C-c 1 w" #'flymake-show-project-diagnostics)
  (keymap-set flymake-mode-map "C-c 1 a" #'my/flymake-toggle-eol)

  (defvar-keymap my/flymake-repeat-map
    :doc "Repeat map for Flymake commands."
    :repeat t
    "n" #'flymake-goto-next-error
    "p" #'flymake-goto-prev-error
    "l" #'flymake-show-buffer-diagnostics
    "w" #'flymake-show-project-diagnostics
    "a" #'my/flymake-toggle-eol)

  (dolist (face '(flymake-error flymake-warning flymake-note))
    (set-face-attribute face nil :foreground 'unspecified)))

(provide 'init-flymake)
;;; init-flymake.el ends here
