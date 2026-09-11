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

;; (use-package company
;;   :ensure t
;;   :diminish 'company-mode
;;   :hook (after-init . global-company-mode)
;;   :custom
;;   (company-format-margin-function #'company-text-icons-margin)
;;   ;; (company-idle-delay 0.2)
;;   (company-minimum-prefix-length 3)
;;   (company-selection-wrap-around t)
;;   (company-tooltip-align-annotations t)
;;   (company-dabbrev-downcase nil)
;;   (company-dabbrev-ignore-case t)
;;   (company-tooltip-minimum-width 30)
;;   (company-tooltip-limit 10)
;;   (company-transformers '(company-sort-by-occurrence))
;;   :init
;;   (setq company-backends '(company-capf company-files company-keywords))
;;   (setq company-frontends
;;         '(company-pseudo-tooltip-frontend  ; always show candidates in overlay tooltip
;;           company-echo-metadata-frontend))  ; show selected candidate docs in echo area
;;   :bind (:map company-active-map
;;               ("TAB" . company-complete-selection)
;;               ("<tab>" . company-complete-selection)
;;               ("C-j" . company-select-next)
;;               ("C-k" . company-select-previous)
;;               ("<escape>" . company-abort)))

(use-package corfu
  ;; :straight (corfu :files (:defaults "extensions/*"))
  :custom
  (corfu-cycle t)                ;; Enable cycling for corfu-next/previous
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-separator ?\s)          ;; Orderless field separator
  (corfu-auto-prefix 2)
  (corfu-history-mode 1)
  ;; (add-to-list 'savehist-additional-variables 'corfu-history)
  (corfu-min-width 45)
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect-first nil)    ;; Disable candidate preselection
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  :init
  (corfu-popupinfo-mode)
  (global-corfu-mode))

(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'authinfo-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

;; (use-package cape
;;   :init
;;   (add-to-list 'completion-at-point-functions #'cape-file)
;;   (add-to-list 'completion-at-point-functions #'cape-keyword))

(use-package kind-icon
  :config
  (setq kind-icon-default-face 'corfu-default)
  (setq kind-icon-default-style '(:padding 0 :stroke 0 :margin 0 :radius 0 :height 0.9 :scale 1))
  (setq kind-icon-blend-frac 0.08)
  (setq kind-icon-use-icons nil)
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
  (add-hook 'counsel-load-theme #'(lambda () (interactive) (kind-icon-reset-cache)))
  (add-hook 'load-theme         #'(lambda () (interactive) (kind-icon-reset-cache))))

;; (use-package consult
;;   :bind (;; ("C-s"   . consult-line)
;;          ("C-x b" . consult-buffer)
;;          ("M-y"   . consult-yank-pop)
;;          ("C-c g" . consult-ripgrep)))

(provide 'mod-completion)
;;; mod-completion.el ends here
