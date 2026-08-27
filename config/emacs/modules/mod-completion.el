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

(use-package company
  :ensure t
  :diminish 'company-mode
  :hook (after-init . global-company-mode)
  :custom
  (company-format-margin-function #'company-text-icons-margin)
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 2)
  (company-selection-wrap-around t)
  (company-tooltip-align-annotations t)
  (company-dabbrev-downcase nil)
  (company-dabbrev-ignore-case t)
  (company-tooltip-minimum-width 30)
  (company-tooltip-limit 10)
  (company-transformers '(company-sort-by-occurrence))
  :init
  (setq company-backends '(company-capf company-files company-keywords))
  (setq company-frontends
        '(company-pseudo-tooltip-frontend  ; always show candidates in overlay tooltip
          company-echo-metadata-frontend))  ; show selected candidate docs in echo area
  :bind (:map company-active-map
              ("TAB" . company-complete-selection)
              ("<tab>" . company-complete-selection)
              ("C-j" . company-select-next)
              ("C-k" . company-select-previous)
              ("<escape>" . company-abort)))

;; (use-package consult
;;   :bind (;; ("C-s"   . consult-line)
;;          ("C-x b" . consult-buffer)
;;          ("M-y"   . consult-yank-pop)
;;          ("C-c g" . consult-ripgrep)))

(provide 'mod-completion)
;;; mod-completion.el ends here
