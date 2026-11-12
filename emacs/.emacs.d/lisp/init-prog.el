;; -*- lexical-binding: t; -*-

(setq auto-mode-alist
      (append '(("Dockerfile" . conf-mode)
                ("\\.env\\'" . conf-mode)
                ("\\.gitignore\\'" . conf-mode))
              auto-mode-alist))

(use-package whitespace
  :straight nil
  :hook (prog-mode . whitespace-mode)
  :custom
  (whitespace-style '(face trailing tabs tab-mark))
  (whitespace-display-mappings
   '((space-mark 32 [183] [46])
     (tab-mark 9 [8594 9] [92 9]))))

(use-package hideshow
  :straight nil
  :hook (prog-mode . hs-minor-mode)
  :diminish hs-minor-mode
  :config
  (defun toggle-fold ()
    "Toggle folding of the block at the end of the current line."
    (interactive)
    (save-excursion
      (end-of-line)
      (hs-toggle-hiding)))
  (keymap-global-set "C-c t f" #'toggle-fold))

(use-package symbol-overlay
  :bind (("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev))
  :hook (prog-mode . symbol-overlay-mode)
  :diminish symbol-overlay-mode
  :config
  (setq symbol-overlay-idle-time 2.0))

(use-package syntax-subword
  :custom (syntax-subword-skip-spaces t)
  :diminish syntax-subword-mode
  ;; :hook (prog-mode . syntax-subword-mode)
  :bind (:map prog-mode-map
              ("M-F" . syntax-subword-forward)
              ("M-B" . syntax-subword-backward)
              ("M-D" . syntax-subword-kill)
              ("<M-S-backspace>" . syntax-subword-backward-kill)))

(add-hook 'prog-mode-hook 'subword-mode)

(use-package quickrun
  :ensure t
  :bind ("C-c r" . quickrun))

(use-package devdocs-browser)

(use-package apheleia
  :ensure t
  :diminish apheleia-mode
  :config
  (apheleia-global-mode +1))

(provide 'init-prog)
