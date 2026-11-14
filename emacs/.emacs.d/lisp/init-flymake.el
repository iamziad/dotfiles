;; -*- lexical-binding: t; -*-

(use-package flymake
  :ensure nil
  :hook ((prog-mode . flymake-mode)
         (html-mode . flymake-mode)
         (mhtml-mode . flymake-mode)
         (html-ts-mode . flymake-mode)
         (mhtml-ts-mode . flymake-mode)
         (css-mode . flymake-mode)
         (css-ts-mode . flymake-mode)
         (scss-mode . flymake-mode)
         (json-mode . flymake-mode)
         (json-ts-mode . flymake-mode))
  :bind
  (:map flymake-mode-map
        ("C-c 1 n" . flymake-goto-next-error)
        ("C-c 1 p" . flymake-goto-prev-error)
        ("C-c 1 l" . flymake-show-buffer-diagnostics)
        ("C-c 1 w" . flymake-show-project-diagnostics)
        ("C-c 1 a" . my/flymake-toggle-eol))
  :custom
  (flymake-no-changes-timeout 0.8)
  (flymake-start-on-save-buffer t)
  (flymake-wrap-around nil)
  (flymake-indicator-type 'margins)
  (flymake-show-diagnostics-at-end-of-line nil)
  :config
  (defun my/flymake-toggle-eol (&optional fancy)
    "Toggle Flymake diagnostics at end of line.
With prefix argument, show all diagnostics."
    (interactive "P")
    (setq-local
     flymake-show-diagnostics-at-end-of-line
     (if flymake-show-diagnostics-at-end-of-line
         nil
       (if fancy 'fancy 'short)))
    (when (bound-and-true-p flymake-mode)
      (flymake-mode -1)
      (flymake-mode 1))
    (message "Flymake EOL diagnostics: %s"
             (or flymake-show-diagnostics-at-end-of-line "off")))

  (defvar-keymap my/flymake-repeat-map
    :doc "Repeat map for Flymake commands."
    :repeat t
    "n" #'flymake-goto-next-error
    "p" #'flymake-goto-prev-error
    "l" #'flymake-show-buffer-diagnostics
    "w" #'flymake-show-project-diagnostics
    "a" #'my/flymake-toggle-eol))

(with-eval-after-load 'flymake
  (dolist (face '(flymake-error
                  flymake-warning
                  flymake-note))
    (set-face-attribute face nil
                        :foreground 'unspecified)))

(provide 'init-flymake)
