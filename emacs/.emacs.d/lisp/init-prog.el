;; -*- lexical-binding: t; -*-

;;; File associations

(setq auto-mode-alist
      (append '(("Dockerfile" . conf-mode)
                ("\\.env\\'" . conf-mode)
                ("\\.gitignore\\'" . conf-mode))
              auto-mode-alist))

;;; Bullshit

(use-package markdown-mode
  :ensure t
  :mode
  ("\\.md\\'" . gfm-mode)
  :hook
  ((markdown-mode) .
   (lambda ()
     outline-minor-mode
     ))
  :custom-face
  (markdown-code-face ((t (:inherit default)))))

;;; Debugging

(use-package dape
  :ensure t
  :init
  (setq dape-key-prefix "\C-cd")
  :custom
  (dape-buffer-window-arrangement 'right))

;;; Folding

(defun my/toggle-fold ()
  "Toggle folding of the block at the end of the current line."
  (interactive)
  (save-excursion
    (end-of-line)
    (hs-toggle-hiding)))

(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode)
  :diminish hs-minor-mode)

;;; Highlighting

(use-package hl-todo
  :ensure t
  :hook ((prog-mode . hl-todo-mode)
         (text-mode . hl-todo-mode))
  ;; :config
  ;; (setq hl-todo-keyword-faces
  ;;       (mapcar (lambda (entry) (cons (car entry) "#fb4934"))
  ;;               hl-todo-keyword-faces))
  )

;;; Navigation

(use-package symbol-overlay
  :ensure t
  :diminish symbol-overlay-mode
  :hook (prog-mode . symbol-overlay-mode)
  :custom
  (symbol-overlay-scope t)
  (symbol-overlay-idle-time 1.5)
  :config
  (keymap-set symbol-overlay-mode-map "M-n" #'symbol-overlay-jump-next)
  (keymap-set symbol-overlay-mode-map "M-p" #'symbol-overlay-jump-prev)
  (keymap-set symbol-overlay-mode-map "C-c C-s r" #'symbol-overlay-rename)
  (keymap-set symbol-overlay-mode-map "C-c C-s k" #'symbol-overlay-remove-all)
  (keymap-set symbol-overlay-mode-map "C-c C-s q" #'symbol-overlay-query-replace)
  (keymap-set symbol-overlay-mode-map "C-c C-s t" #'symbol-overlay-toggle-in-scope)
  (keymap-set symbol-overlay-mode-map "C-c C-s n" #'symbol-overlay-jump-next)
  (keymap-set symbol-overlay-mode-map "C-c C-s p" #'symbol-overlay-jump-prev))

(use-package syntax-subword
  :ensure t
  :custom (syntax-subword-skip-spaces t)
  :diminish syntax-subword-mode
  ;; :hook (prog-mode . syntax-subword-mode)
  :bind (:map prog-mode-map
              ("M-F" . syntax-subword-forward)
              ("M-B" . syntax-subword-backward)
              ("M-D" . syntax-subword-kill)
              ("<M-S-backspace>" . syntax-subword-backward-kill)))
(add-hook 'prog-mode-hook 'subword-mode)

;;; Misc

(use-package whitespace
  :ensure nil
  :hook (prog-mode . whitespace-mode)
  :custom
  (whitespace-style '(face trailing tabs tab-mark))
  (whitespace-display-mappings
   '((space-mark 32 [183] [46])
     (tab-mark 9 [8594 9] [92 9]))))

(use-package quickrun
  :ensure t
  :bind ("C-c r" . quickrun))

(use-package devdocs-browser
  :ensure t)

(use-package apheleia
  :ensure t
  :diminish apheleia-mode
  :config
  (apheleia-global-mode +1))

(use-package breadcrumb
  :ensure t
  :hook ((java-mode . breadcrumb-local-mode)))

(provide 'init-prog)
