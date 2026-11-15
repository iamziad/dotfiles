;;; Tabs  -*- lexical-binding: t; -*-

;; tab bar
(setq tab-bar-show 1)

(dolist (i (number-sequence 1 9))
  (keymap-global-set (format "M-%d" i)
                     (lambda () (interactive) (tab-bar-select-tab i))))
(keymap-global-set "C-x t o" #'tab-close-other)

(use-package vim-tab-bar
  :ensure t
  :init
  (vim-tab-bar-mode 1)
  :config
  (customize-set-variable 'tab-bar-show 1))

;; tab line
;; (global-tab-line-mode 1)
;; (setq tab-line-close-button-show t
;;       tab-line-new-button-show t
;;       tab-line-tabs-function #'tab-line-tabs-buffer-groups)
;; (setq tab-line-exclude-modes '(completion-list-mode elisp-compile-mode dired-mode))
;;   (global-set-key (kbd "M-k") #'tab-line-switch-to-next-tab)
;;   (global-set-key (kbd "M-j")  #'tab-line-switch-to-prev-tab)

(provide 'init-tabs)
;;; init-tabs.el ends here
