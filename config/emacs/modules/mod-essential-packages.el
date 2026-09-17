;;; mod-essential-packages.el -*- lexical-binding: t; -*-

;;; --------------------------------------------------------------------------

(use-package diminish
  :ensure t
  :config
  (diminish 'visual-line-mode)
  (diminish 'eldoc-mode))

;;; --------------------------------------------------------------------------

(use-package beacon
  :diminish beacon-mode
  :init
  (beacon-mode 1)

  :config
  (add-hook 'restclient-mode-hook
            (lambda ()
              (beacon-mode -1)))

  (add-hook 'restclient-mode-hook
            (lambda ()
              (add-hook 'kill-buffer-hook
                        (lambda ()
                          (beacon-mode 1))
                        nil t))))

;;; --------------------------------------------------------------------------

;; gc-cons-threshold in early-init.el is a fixed 64mb ceiling for the whole
;; session. gcmh instead raises the threshold while Emacs is active and only
;; runs a full GC when it goes idle - the visible "hang" while lsp-mode parses
;; a big JSON-RPC response is very often just a GC pause, and this is the
;; standard fix for it.
(use-package gcmh
  :diminish gcmh-mode
  :ensure t
  :config
  (gcmh-mode 1)
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 64 1024 1024)))

;;; --------------------------------------------------------------------------

(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)
  :custom
  (persp-mode-prefix-key (kbd "C-c C-p"))
  :init
  (persp-mode))

;;; --------------------------------------------------------------------------

(use-package smartparens
  :diminish 'smartparens-mode
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config)
  :bind
  ("C-c s r" . sp-rewrap-sexp))

;;; --------------------------------------------------------------------------

(use-package iy-go-to-char
  :ensure t
  :config
  :bind (("M-f" . iy-go-to-char)
         ("M-b" . iy-go-to-char-backward)))

;;; --------------------------------------------------------------------------

(use-package anzu
  :ensure t
  :diminish anzu-mode
  :config (global-anzu-mode 1))

;;; --------------------------------------------------------------------------

(use-package multiple-cursors
  :ensure t
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-M-<"   . mc/skip-to-previous-like-this)
         ("C-M->"   . mc/skip-to-next-like-this)
         ("C-c m d" . mc/mark-all-dwim)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m n" . electric-newline-and-maybe-indent)
         ("C-c m e" . mc/edit-lines))
  :config
  (require 'mc-hide-unmatched-lines-mode)
  (setq mc/always-run-for-all t))

;;; --------------------------------------------------------------------------

;; (use-package ace-window
;;   :ensure t
;;   :bind (("M-o" . ace-window)
;;          ("M-s" . ace-swap-window))
;;   :config
;;   (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;;; --------------------------------------------------------------------------

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

;;; --------------------------------------------------------------------------

(use-package drag-stuff
  :ensure t
  :diminish drag-stuff-mode
  :config
  (drag-stuff-global-mode 1)
  :bind
  ("C-S-k" . drag-stuff-up)
  ("C-S-j" . drag-stuff-down))

(provide 'mod-essential-packages)
;;; mod-essential-packages.el ends here
