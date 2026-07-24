;;; mod-completion.el --- Minibuffer + in-buffer completion -*- lexical-binding: t; -*-

(use-package vertico
  :init
  (vertico-mode)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package corfu
  :ensure t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)           ; Minimum length of prefix for completion
  (corfu-auto-delay 0)            ; No delay for completion
  (corfu-popupinfo-delay '(0.5 . 0.2))  ; Automatically update info popup after that numver of seconds
  (corfu-preview-current 'insert) ; insert previewed candidate
  (corfu-preselect 'prompt)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC"      . corfu-insert-separator)
              ("TAB"        . corfu-next)
              ([tab]        . corfu-next)
              ("S-TAB"      . corfu-previous)
              ([backtab]    . corfu-previous)
              ("S-<return>" . corfu-insert)
              ("RET"        . corfu-insert))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode) ; Popup completion info
  :config
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t
                                   corfu-quit-no-match t
                                   corfu-auto nil)
              (corfu-mode))
            nil
            t))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;; (use-package consult
;;   :bind (("C-s"   . consult-line)
;;          ("C-x b" . consult-buffer)
;;          ("M-y"   . consult-yank-pop)
;;          ("C-c g" . consult-ripgrep)))

;; (use-package company
;;   :ensure t
;;   :hook (after-init . global-company-mode)
;;   :custom
;;   (company-format-margin-function #'company-text-icons-margin)
;;   :config
;;   (setq company-backends
;;         '((company-capf :with company-yasnippet)))
;;   (setq company-idle-delay 0.1)
;;   (setq company-minimum-prefix-length 2)
;;   (setq company-selection-wrap-around t)
;;   (setq company-tooltip-align-annotations t)
;;   (setq company-dabbrev-downcase nil)
;;   (setq company-dabbrev-ignore-case t)
;;   (setq company-tooltip-minimum-width 30)
;;   (setq company-tooltip-limit 10)
;;   :bind (:map company-active-map
;;               ("TAB" . company-complete-selection)
;;               ("<tab>" . company-complete-selection)
;;               ("C-j" . company-select-next)
;;               ("C-k" . company-select-previous)
;;               ("<escape>" . company-abort)))

(provide 'mod-completion)
;;; mod-completion.el ends here
