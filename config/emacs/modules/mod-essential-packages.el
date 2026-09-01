;;; mod-essential-packages.el


(use-package diminish
  :ensure t
  :config
  (diminish 'visual-line-mode)
  (diminish 'eldoc-mode))

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
