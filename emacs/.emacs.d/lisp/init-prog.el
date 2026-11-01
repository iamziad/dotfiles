;; -*- lexical-binding: t; -*-

(setq auto-mode-alist
      (append '(("Dockerfile" . conf-mode)
                ("\\.env\\'" . conf-mode)
                ("\\.gitignore\\'" . conf-mode))
              auto-mode-alist))

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

(use-package restclient
  :ensure t
  :mode ("\\.http\\'" . restclient-mode)
  :mode ("\\.rest\\'" . restclient-mode))

(provide 'init-prog)
