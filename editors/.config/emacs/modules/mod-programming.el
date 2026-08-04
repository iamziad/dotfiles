;;; mod-programming.el --- programming configuration -*- lexical-binding: t; -*-

;; Basic Indentation & Formatting
(setq-default indent-tabs-mode nil
              tab-width 4
              standard-indent 4
              c-basic-offset 4
              compilation-scroll-output t)

;; Dev tools
(setq gdb-many-windows t
      gdb-show-main t)

;; Makefiles MUST use real tabs
(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))

;; Performance boost: disable bidi reordering for prog-mode
(add-hook 'prog-mode-hook
          (lambda ()
            (setq bidi-paragraph-direction 'left-to-right
                  bidi-display-reordering nil)))

;; Misc
(global-subword-mode +1)

(use-package hl-todo
  :init (global-hl-todo-mode 1))

;;; --------------------------------------------------------------------------
;;; Language Specific Indentation Settings
;;; --------------------------------------------------------------------------

;; C / C++
(setq c-default-style "k&r"
      c-ts-mode-indent-offset 4
      c-ts-mode-indent-style 'k&r)

(add-hook 'c-ts-base-mode-hook (lambda ()
                                 (local-set-key (kbd "RET")
                                                #'reindent-then-newline-and-indent)))

;; Java
(setq java-ts-mode-indent-offset 4)

;; JavaScript / TypeScript
(setq js-indent-level 2
      typescript-ts-mode-indent-offset 2)

(with-eval-after-load 'js-mode 'typescript-ts-mode 'tsx-ts-mode 'web-mode
                      (define-key js-mode-map (kbd "M-.") 'lsp-ui-peek-find-definitions))


;; HTML / CSS
(setq sgml-basic-offset 2
      css-indent-offset 2
      css-ts-mode-indent-offset 2)

;;; --------------------------------------------------------------------------
;;; Extra Language Modes
;;; --------------------------------------------------------------------------

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")


(provide 'mod-programming)
;;; mod-programming.el ends here
